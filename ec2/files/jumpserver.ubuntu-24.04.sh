#!/bin/bash
set -euo pipefail
MARKER_FILE="/var/lib/cloud/jumpserver-installed"
LOG_FILE="/var/log/jumpserver-install.log"
STDERR_LOG="/var/log/jumpserver-install-stderr.log"
log(){ local msg="$(date '+%Y-%m-%d %H:%M:%S') $*"; echo "$msg" >> "${LOG_FILE}" 2>/dev/null || true; echo "$msg" >&2; }
error_exit(){ log "ERROR: $1"; exit 1; }
[ -f "${MARKER_FILE}" ] && { log "JumpServer already installed"; exit 0; }
mkdir -p "$(dirname "${LOG_FILE}")" "$(dirname "${STDERR_LOG}")"
exec 2> >(tee -a "${STDERR_LOG}" >&2)
log "Starting JumpServer installation"
export DEBIAN_FRONTEND=noninteractive
PROJECT="${PROJECT:-devops}"
APP="${APP:-jump}"
ENVIRONMENT="${ENVIRONMENT:-production}"
cat >> /etc/environment <<EOF
PROJECT=${PROJECT}
APP=${APP}
ENVIRONMENT=${ENVIRONMENT}
EOF
cat > /etc/profile.d/jump-prompt.sh <<'EOF'
if [ -f /etc/environment ]; then
    set -a; . /etc/environment; set +a
    case "${ENVIRONMENT}" in production) C="\033[1;31m";; staging) C="\033[1;33m";; testing) C="\033[1;32m";; *) C="\033[1;36m";; esac
    export PS1="[${C}${PROJECT}-${APP}-${ENVIRONMENT}\033[0m] \u@\h:\w\$ "
else
    export PS1="\u@\h:\w\$ "
fi
EOF
chmod 644 /etc/profile.d/jump-prompt.sh
JUMPSERVER_VERSION="${JUMPSERVER_VERSION:-v2.28.8}"
JUMPSERVER_DB_HOST="${JUMPSERVER_DB_HOST:-localhost}"
JUMPSERVER_DB_PORT="${JUMPSERVER_DB_PORT:-3306}"
JUMPSERVER_DB_USER="${JUMPSERVER_DB_USER:-root}"
JUMPSERVER_DB_NAME="${JUMPSERVER_DB_NAME:-jumpserver}"
JUMPSERVER_REDIS_HOST="${JUMPSERVER_REDIS_HOST:-localhost}"
JUMPSERVER_REDIS_PORT="${JUMPSERVER_REDIS_PORT:-6379}"
JUMPSERVER_HTTP_PORT="${JUMPSERVER_HTTP_PORT:-80}"
JUMPSERVER_SSH_PORT="${JUMPSERVER_SSH_PORT:-2222}"
JUMPSERVER_RDP_PORT="${JUMPSERVER_RDP_PORT:-3389}"
JUMPSERVER_DOCKER_SUBNET="${JUMPSERVER_DOCKER_SUBNET:-192.168.250.0/24}"
JUMPSERVER_LOG_LEVEL="${JUMPSERVER_LOG_LEVEL:-ERROR}"
gen_random(){
    local len=$1 out=""
    if command -v openssl &>/dev/null; then
        T=$(mktemp)
        openssl rand -base64 $len > "$T" 2>/dev/null && [ -s "$T" ] && out=$(tr -d "=+/" < "$T" | head -c $len)
        rm -f "$T"
    fi
    [ -z "$out" ] && {
        T=$(mktemp)
        dd if=/dev/urandom bs=$len count=1 > "$T" 2>/dev/null && [ -s "$T" ] && {
            T2=$(mktemp)
            base64 < "$T" > "$T2" 2>/dev/null && [ -s "$T2" ] && out=$(tr -d "=+/" < "$T2" | head -c $len)
            rm -f "$T2"
        }
        rm -f "$T"
    }
    [ -z "$out" ] && out="JS_$(date +%s)_$(dd if=/dev/urandom bs=10 count=1 2>/dev/null | base64 | tr -d "=+/" | head -c 10)"
    while [ ${#out} -lt $len ]; do
        EXTRA=$(dd if=/dev/urandom bs=5 count=1 2>/dev/null | base64 | tr -d "=+/" | head -c 5)
        out="${out}${EXTRA}"
        [ ${#out} -ge $((len*2)) ] && break
    done
    echo -n "${out:0:$len}"
}
log "Generating secrets if needed"
[ -z "${JUMPSERVER_SECRET_KEY:-}" ] && {
    JUMPSERVER_SECRET_KEY=$(gen_random 50)
    echo "${JUMPSERVER_SECRET_KEY}" > /root/.jumpserver-secret-key
    chmod 600 /root/.jumpserver-secret-key
}
[ -z "${JUMPSERVER_BOOTSTRAP_TOKEN:-}" ] && {
    JUMPSERVER_BOOTSTRAP_TOKEN=$(gen_random 24)
    echo "${JUMPSERVER_BOOTSTRAP_TOKEN}" > /root/.jumpserver-bootstrap-token
    chmod 600 /root/.jumpserver-bootstrap-token
}
[ -z "${JUMPSERVER_DB_PASSWORD:-}" ] && error_exit "JUMPSERVER_DB_PASSWORD is required"
log "Updating system packages"
apt-get update -qq || error_exit "Failed to update package lists"
apt-get upgrade -y -qq -o Dpkg::Options::="--force-confold" --no-install-recommends || log "WARNING: Package upgrade failed"
log "Installing packages"
apt-get install -y -qq curl wget tar gettext iptables python3 python3-pip ca-certificates gnupg lsb-release net-tools iproute2 tcpdump htop vim less strace lsof dnsutils telnet netcat-openbsd jq tree zip mysql-client redis-tools postgresql-client ufw fail2ban || log "WARNING: Some packages failed to install"
apt-get install -y -qq unattended-upgrades || log "WARNING: unattended-upgrades install failed"
cat > /etc/apt/apt.conf.d/50unattended-upgrades <<'EOF'
Unattended-Upgrade::Allowed-Origins {"${distro_id}:${distro_codename}-security";"${distro_id}ESMApps:${distro_codename}-apps-security";"${distro_id}ESM:${distro_codename}-infra-security";};
Unattended-Upgrade::Package-Blacklist {};
Unattended-Upgrade::AutoFixInterruptedDpkg "true";
Unattended-Upgrade::MinimalSteps "true";
Unattended-Upgrade::InstallOnShutdown "false";
Unattended-Upgrade::Remove-Unused-Kernel-Packages "true";
Unattended-Upgrade::Remove-Unused-Dependencies "true";
Unattended-Upgrade::Automatic-Reboot "false";
Unattended-Upgrade::Automatic-Reboot-WithUsers "false";
Unattended-Upgrade::Automatic-Reboot-Time "02:00";
EOF
cat > /etc/apt/apt.conf.d/20auto-upgrades <<'EOF'
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
APT::Periodic::Download-Upgradeable-Packages "1";
APT::Periodic::AutocleanInterval "7";
EOF
systemctl enable unattended-upgrades && systemctl start unattended-upgrades || log "WARNING: unattended-upgrades service failed"
log "Configuring SSH security"
[ -f /etc/ssh/sshd_config ] && {
    cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup.$(date +%Y%m%d_%H%M%S) || true
    grep -q "^PermitRootLogin" /etc/ssh/sshd_config && sed -i 's/^#*PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config || echo "PermitRootLogin no" >> /etc/ssh/sshd_config
    grep -q "^PasswordAuthentication" /etc/ssh/sshd_config && sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config || echo "PasswordAuthentication no" >> /etc/ssh/sshd_config
    grep -q "^PubkeyAuthentication" /etc/ssh/sshd_config || echo "PubkeyAuthentication yes" >> /etc/ssh/sshd_config
    grep -q "^ClientAliveInterval" /etc/ssh/sshd_config || echo "ClientAliveInterval 300" >> /etc/ssh/sshd_config
    grep -q "^ClientAliveCountMax" /etc/ssh/sshd_config || echo "ClientAliveCountMax 2" >> /etc/ssh/sshd_config
    grep -q "^MaxAuthTries" /etc/ssh/sshd_config || echo "MaxAuthTries 3" >> /etc/ssh/sshd_config
    grep -q "^X11Forwarding" /etc/ssh/sshd_config && sed -i 's/^#*X11Forwarding.*/X11Forwarding no/' /etc/ssh/sshd_config || echo "X11Forwarding no" >> /etc/ssh/sshd_config
    systemctl reload sshd || log "WARNING: Failed to reload SSH daemon"
}
log "Configuring firewall"
ufw --force enable || log "WARNING: Failed to enable UFW"
ufw default deny incoming || log "WARNING: Failed to set default deny incoming"
ufw default allow outgoing || log "WARNING: Failed to set default allow outgoing"
ufw allow ssh || log "WARNING: Failed to allow SSH"
log "Configuring fail2ban"
[ ! -f /etc/fail2ban/jail.local ] && cat > /etc/fail2ban/jail.local <<'EOF'
[DEFAULT]
bantime=3600
findtime=600
maxretry=5
destemail=root@localhost
sendername=Fail2Ban
action=%(action_)s
[sshd]
enabled=true
port=ssh
logpath=%(sshd_log)s
backend=%(sshd_backend)s
maxretry=3
bantime=7200
findtime=600
EOF
systemctl enable fail2ban || log "WARNING: Failed to enable fail2ban"
systemctl start fail2ban || log "WARNING: Failed to start fail2ban"
if ! command -v docker &>/dev/null; then
    log "Installing Docker"
    install -m 0755 -d /etc/apt/keyrings
    TMP_GPG="/tmp/docker.gpg.tmp"
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o "${TMP_GPG}" || error_exit "Failed to download Docker GPG key"
    gpg --dearmor < "${TMP_GPG}" > /etc/apt/keyrings/docker.gpg || error_exit "Failed to process Docker GPG key"
    rm -f "${TMP_GPG}"
    chmod a+r /etc/apt/keyrings/docker.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" > /etc/apt/sources.list.d/docker.list
    apt-get update -qq || error_exit "Failed to update after adding Docker repo"
    apt-get install -y -qq docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin || error_exit "Failed to install Docker"
    systemctl enable docker && systemctl start docker || error_exit "Failed to start Docker"
fi
if ! command -v docker-compose &>/dev/null; then
    log "Installing Docker Compose"
    curl -L "https://github.com/docker/compose/releases/download/v2.24.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose || error_exit "Failed to download Docker Compose"
    chmod +x /usr/local/bin/docker-compose || error_exit "Failed to chmod docker-compose"
fi
if ! command -v kubectl &>/dev/null; then
    log "Installing kubectl"
    ARCH=$(uname -m)
    case "$ARCH" in x86_64) KARCH="amd64";; aarch64|arm64) KARCH="arm64";; *) error_exit "Unsupported architecture: ${ARCH}";; esac
    KURL="https://dl.k8s.io/release/v1.30.0/bin/linux/${KARCH}/kubectl"
    for i in 1 2 3; do
        curl -LO --connect-timeout 10 --max-time 60 "${KURL}" && break
        [ $i -eq 3 ] && error_exit "Failed to download kubectl"
        sleep $((i*5))
    done
    chmod +x kubectl && mv kubectl /usr/local/bin/kubectl || error_exit "Failed to install kubectl"
fi
log "Downloading JumpServer installer ${JUMPSERVER_VERSION}"
INSTALL_DIR="/opt/jumpserver-installer"
mkdir -p "${INSTALL_DIR}" && cd "${INSTALL_DIR}" || error_exit "Failed to change to installation directory"
INSTALLER_TAR="jumpserver-installer-${JUMPSERVER_VERSION}.tar.gz"
INSTALLER_URL="https://github.com/jumpserver/installer/releases/download/${JUMPSERVER_VERSION}/${INSTALLER_TAR}"
for i in 1 2 3; do
    wget -q --timeout=30 --tries=3 "${INSTALLER_URL}" -O "${INSTALLER_TAR}" && break
    [ $i -eq 3 ] && error_exit "Failed to download JumpServer installer"
    sleep $((i*5))
done
log "Extracting installer"
tar -xf "${INSTALLER_TAR}" || error_exit "Failed to extract installer"
rm -f "${INSTALLER_TAR}"
INSTALLER_DIR_REL=$(find . -maxdepth 1 -type d -name "jumpserver-installer-*" | head -n 1)
[ -z "${INSTALLER_DIR_REL}" ] && error_exit "Failed to find installer directory"
INSTALLER_DIR="$(cd "${INSTALLER_DIR_REL}" && pwd)"
cd "${INSTALLER_DIR}" || error_exit "Failed to change to installer directory"
log "Creating configuration file"
cat > config.txt <<EOF
Version=${JUMPSERVER_VERSION}
SECRET_KEY=${JUMPSERVER_SECRET_KEY}
BOOTSTRAP_TOKEN=${JUMPSERVER_BOOTSTRAP_TOKEN}
DB_HOST=${JUMPSERVER_DB_HOST}
DB_PORT=${JUMPSERVER_DB_PORT}
DB_USER=${JUMPSERVER_DB_USER}
DB_PASSWORD=${JUMPSERVER_DB_PASSWORD}
DB_NAME=${JUMPSERVER_DB_NAME}
REDIS_HOST=${JUMPSERVER_REDIS_HOST}
REDIS_PORT=${JUMPSERVER_REDIS_PORT}
REDIS_PASSWORD=${JUMPSERVER_REDIS_PASSWORD:-}
HTTP_PORT=${JUMPSERVER_HTTP_PORT}
SSH_PORT=${JUMPSERVER_SSH_PORT}
RDP_PORT=${JUMPSERVER_RDP_PORT}
DOCKER_SUBNET=${JUMPSERVER_DOCKER_SUBNET}
SESSION_EXPIRE_AT_BROWSER_CLOSE=True
LOG_LEVEL=${JUMPSERVER_LOG_LEVEL}
EOF
log "Checking database connectivity (will skip if localhost)"
for i in $(seq 1 60); do
    mysql -h "${JUMPSERVER_DB_HOST}" -P "${JUMPSERVER_DB_PORT}" -u "${JUMPSERVER_DB_USER}" -p"${JUMPSERVER_DB_PASSWORD}" -e "SELECT 1" &>/dev/null 2>&1 && { log "Database is ready"; break; }
    [ "${JUMPSERVER_DB_HOST}" = "localhost" ] && [ $i -eq 1 ] && log "Using localhost - installer will install MySQL"
    [ $i -eq 60 ] && log "WARNING: Database connection failed - installer will install MySQL if using localhost"
    [ $i -lt 60 ] && sleep 2
done
log "Checking Redis connectivity (will skip if localhost)"
for i in $(seq 1 60); do
    if [ -n "${JUMPSERVER_REDIS_PASSWORD:-}" ]; then
        redis-cli -h "${JUMPSERVER_REDIS_HOST}" -p "${JUMPSERVER_REDIS_PORT}" -a "${JUMPSERVER_REDIS_PASSWORD}" ping &>/dev/null 2>&1 && { log "Redis is ready"; break; }
    else
        redis-cli -h "${JUMPSERVER_REDIS_HOST}" -p "${JUMPSERVER_REDIS_PORT}" ping &>/dev/null 2>&1 && { log "Redis is ready"; break; }
    fi
    [ "${JUMPSERVER_REDIS_HOST}" = "localhost" ] && [ $i -eq 1 ] && log "Using localhost - installer will install Redis"
    [ $i -eq 60 ] && log "WARNING: Redis connection failed - installer will install Redis if using localhost"
    [ $i -lt 60 ] && sleep 2
done
[ -f "./jmsctl.sh" ] || error_exit "jmsctl.sh not found"
chmod +x ./jmsctl.sh
INSTALL_LOG="${INSTALLER_DIR}/install-output.log"
log "Running JumpServer installer (this may take several minutes)"
./jmsctl.sh install < /dev/null > "${INSTALL_LOG}" 2>&1 || {
    log "ERROR: JumpServer installation failed"
    cat "${INSTALL_LOG}" >> "${LOG_FILE}" 2>/dev/null || true
    error_exit "JumpServer installation failed - check ${LOG_FILE} and ${INSTALL_LOG}"
}
log "JumpServer installation completed successfully"
cat "${INSTALL_LOG}" >> "${LOG_FILE}" 2>/dev/null || true
sleep 10
log "Starting JumpServer services"
START_LOG="${INSTALLER_DIR}/start-output.log"
./jmsctl.sh start > "${START_LOG}" 2>&1 && cat "${START_LOG}" >> "${LOG_FILE}" 2>/dev/null || log "WARNING: Start command failed"
sleep 10
STATUS_LOG="${INSTALLER_DIR}/status-output.log"
./jmsctl.sh status > "${STATUS_LOG}" 2>&1 && cat "${STATUS_LOG}" >> "${LOG_FILE}" 2>/dev/null || log "WARNING: Status check failed"
touch "${MARKER_FILE}" || true
log "JumpServer installation script completed"
log "Securing SSH authorized_keys file"
[ -f /home/ubuntu/.ssh/authorized_keys ] && {
    chmod 600 /home/ubuntu/.ssh/authorized_keys || log "WARNING: Failed to set permissions on authorized_keys"
    chattr +i /home/ubuntu/.ssh/authorized_keys || log "WARNING: Failed to lock authorized_keys file"
    log "authorized_keys file locked successfully"
} || log "WARNING: authorized_keys file not found"
exit 0
