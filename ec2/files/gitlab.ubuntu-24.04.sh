#!/bin/bash
set -euo pipefail
MARKER_FILE="/var/lib/cloud/gitlab-installed"
LOG_FILE="/var/log/gitlab-install.log"
STDERR_LOG="/var/log/gitlab-install-stderr.log"
log(){ local msg="$(date '+%Y-%m-%d %H:%M:%S') $*"; echo "$msg" >> "${LOG_FILE}" 2>/dev/null || true; echo "$msg" >&2; }
error_exit(){ log "ERROR: $1"; exit 1; }
[ -f "${MARKER_FILE}" ] && { log "GitLab already installed"; exit 0; }
mkdir -p "$(dirname "${LOG_FILE}")" "$(dirname "${STDERR_LOG}")"
exec 2> >(tee -a "${STDERR_LOG}" >&2)
log "Starting GitLab installation"
export DEBIAN_FRONTEND=noninteractive
PROJECT="${PROJECT:-devops}"
APP="${APP:-gitlab}"
ENVIRONMENT="${ENVIRONMENT:-production}"
cat >> /etc/environment <<EOF
PROJECT=${PROJECT}
APP=${APP}
ENVIRONMENT=${ENVIRONMENT}
EOF
cat > /etc/profile.d/gitlab-prompt.sh <<'EOF'
if [ -f /etc/environment ]; then
    set -a; . /etc/environment; set +a
    case "${ENVIRONMENT}" in production) C="\033[1;31m";; staging) C="\033[1;33m";; testing) C="\033[1;32m";; *) C="\033[1;36m";; esac
    export PS1="[${C}${PROJECT}-${APP}-${ENVIRONMENT}\033[0m] \u@\h:\w\$ "
else
    export PS1="\u@\h:\w\$ "
fi
EOF
chmod 644 /etc/profile.d/gitlab-prompt.sh
GITLAB_EXTERNAL_URL="${GITLAB_EXTERNAL_URL:-http://gitlab.example.com}"
GITLAB_HTTP_PORT="${GITLAB_HTTP_PORT:-80}"
GITLAB_HTTPS_PORT="${GITLAB_HTTPS_PORT:-443}"
GITLAB_SSH_PORT="${GITLAB_SSH_PORT:-22}"
log "Updating system packages"
apt-get update -qq || error_exit "Failed to update package lists"
apt-get upgrade -y -qq -o Dpkg::Options::="--force-confold" --no-install-recommends || log "WARNING: Package upgrade failed"
log "Installing required packages"
apt-get install -y -qq curl openssh-server ca-certificates postfix wget tar gettext iptables python3 python3-pip gnupg lsb-release net-tools iproute2 tcpdump htop vim less strace lsof dnsutils telnet netcat-openbsd jq tree zip ufw fail2ban || log "WARNING: Some packages failed to install"
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
ufw allow ${GITLAB_HTTP_PORT}/tcp || log "WARNING: Failed to allow HTTP port ${GITLAB_HTTP_PORT}"
ufw allow ${GITLAB_HTTPS_PORT}/tcp || log "WARNING: Failed to allow HTTPS port ${GITLAB_HTTPS_PORT}"
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
log "Adding GitLab package repository"
install -m 0755 -d /etc/apt/keyrings
TMP_SCRIPT="/tmp/gitlab-repo-script.sh"
for i in 1 2 3; do
    curl -fsSL https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh -o "${TMP_SCRIPT}" && break
    [ $i -eq 3 ] && error_exit "Failed to download GitLab repository script"
    sleep $((i*5))
done
chmod +x "${TMP_SCRIPT}"
bash "${TMP_SCRIPT}" || {
    log "WARNING: GitLab repository script failed, trying manual setup"
    curl -fsSL https://packages.gitlab.com/gitlab/gitlab-ce/gpgkey | gpg --dearmor -o /etc/apt/keyrings/gitlab.gpg || error_exit "Failed to add GitLab GPG key"
    chmod a+r /etc/apt/keyrings/gitlab.gpg
    echo "deb [signed-by=/etc/apt/keyrings/gitlab.gpg] https://packages.gitlab.com/gitlab/gitlab-ce/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") main" > /etc/apt/sources.list.d/gitlab_gitlab-ce.list
    apt-get update -qq || error_exit "Failed to update after adding GitLab repo"
}
rm -f "${TMP_SCRIPT}"
log "Installing GitLab CE"
EXTERNAL_URL="${GITLAB_EXTERNAL_URL}" apt-get install -y -qq gitlab-ce || error_exit "Failed to install GitLab CE"
log "Configuring GitLab"
gitlab-ctl reconfigure || error_exit "Failed to configure GitLab"
log "Waiting for GitLab to be ready"
for i in $(seq 1 60); do
    gitlab-ctl status &>/dev/null && { log "GitLab is ready"; break; }
    [ $i -eq 60 ] && log "WARNING: GitLab may not be fully ready"
    [ $i -lt 60 ] && sleep 5
done
log "GitLab installation completed successfully"
log "Securing SSH authorized_keys file"
[ -f /home/ubuntu/.ssh/authorized_keys ] && {
    chmod 600 /home/ubuntu/.ssh/authorized_keys || log "WARNING: Failed to set permissions on authorized_keys"
    chattr +i /home/ubuntu/.ssh/authorized_keys || log "WARNING: Failed to lock authorized_keys file"
    log "authorized_keys file locked successfully"
} || log "WARNING: authorized_keys file not found"
touch "${MARKER_FILE}" || true
log "GitLab installation script completed"
log "Initial root password can be found in: /etc/gitlab/initial_root_password"
log "This file will be automatically deleted after 24 hours"
exit 0
