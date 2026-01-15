#!/bin/bash
set -euo pipefail
MARKER_FILE="/var/lib/cloud/netbird-installed"
LOG_FILE="/var/log/netbird-install.log"
STDERR_LOG="/var/log/netbird-install-stderr.log"
log(){ local msg="$(date '+%Y-%m-%d %H:%M:%S') $*"; echo "$msg" >> "${LOG_FILE}" 2>/dev/null || true; echo "$msg" >&2; }
error_exit(){ log "ERROR: $1"; exit 1; }
[ -f "${MARKER_FILE}" ] && { log "NetBird already installed"; exit 0; }
mkdir -p "$(dirname "${LOG_FILE}")" "$(dirname "${STDERR_LOG}")"
exec 2> >(tee -a "${STDERR_LOG}" >&2)
log "Starting NetBird installation"
export DEBIAN_FRONTEND=noninteractive
PROJECT="${PROJECT:-devops}"
APP="${APP:-netbird}"
ENVIRONMENT="${ENVIRONMENT:-production}"
cat >> /etc/environment <<EOF
PROJECT=${PROJECT}
APP=${APP}
ENVIRONMENT=${ENVIRONMENT}
EOF
cat > /etc/profile.d/netbird-prompt.sh <<'EOF'
if [ -f /etc/environment ]; then
    set -a; . /etc/environment; set +a
    case "${ENVIRONMENT}" in production) C="\033[1;31m";; staging) C="\033[1;33m";; testing) C="\033[1;32m";; *) C="\033[1;36m";; esac
    export PS1="[${C}${PROJECT}-${APP}-${ENVIRONMENT}\033[0m] \u@\h:\w\$ "
else
    export PS1="\u@\h:\w\$ "
fi
EOF
chmod 644 /etc/profile.d/netbird-prompt.sh
NETBIRD_SETUP_KEY="${NETBIRD_SETUP_KEY:-}"
NETBIRD_MANAGEMENT_URL="${NETBIRD_MANAGEMENT_URL:-}"
[ -z "${NETBIRD_SETUP_KEY}" ] && error_exit "NETBIRD_SETUP_KEY is required"
log "Updating system packages"
apt-get update -qq || error_exit "Failed to update package lists"
apt-get upgrade -y -qq -o Dpkg::Options::="--force-confold" --no-install-recommends || log "WARNING: Package upgrade failed"
log "Installing required packages"
apt-get install -y -qq curl wget tar gettext iptables python3 python3-pip ca-certificates gnupg lsb-release net-tools iproute2 tcpdump htop vim less strace lsof dnsutils telnet netcat-openbsd jq tree zip ufw fail2ban || log "WARNING: Some packages failed to install"
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
APT::Periodic::Unattended-Upgrade::AutoFixInterruptedDpkg "true";
EOF
log "Configuring UFW firewall"
ufw --force enable || log "WARNING: UFW enable failed"
ufw default deny incoming || log "WARNING: UFW default deny failed"
ufw default allow outgoing || log "WARNING: UFW default allow outgoing failed"
ufw allow ssh || log "WARNING: UFW allow ssh failed"
log "Installing NetBird"
curl -fsSL https://pkgs.netbird.io/install.sh | sh || error_exit "Failed to install NetBird"
log "Configuring NetBird"
if [ -n "${NETBIRD_MANAGEMENT_URL}" ]; then
    log "Setting management URL: ${NETBIRD_MANAGEMENT_URL}"
    netbird management set --url "${NETBIRD_MANAGEMENT_URL}" || log "WARNING: Failed to set management URL"
fi
log "Connecting to NetBird network with setup key"
netbird up --setup-key "${NETBIRD_SETUP_KEY}" || error_exit "Failed to connect to NetBird network"
log "Waiting for NetBird to establish connection"
sleep 5
log "Checking NetBird status"
netbird status || log "WARNING: NetBird status check failed"
log "Enabling NetBird service"
systemctl enable netbird || log "WARNING: Failed to enable NetBird service"
systemctl start netbird || log "WARNING: Failed to start NetBird service"
log "Creating marker file"
touch "${MARKER_FILE}"
log "NetBird installation completed successfully"
log "NetBird status:"
netbird status || true
