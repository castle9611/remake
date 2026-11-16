#!/usr/bin/env bash
set -Eeuo pipefail
cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

if [[ ${1:-} == --help || ${1:-} == -h ]]; then
    echo 'Usage: sudo bash deploy.sh [port]   (default: 8080)'
    exit 0
fi
die() { echo "Error: $*" >&2; exit 1; }
[[ $# -le 1 ]] || die 'Usage: sudo bash deploy.sh [port]'
port=${1:-8080}
[[ $port =~ ^[1-9][0-9]{0,4}$ ]] && ((port <= 65535)) || die 'Port must be between 1 and 65535.'
[[ $(uname -s) == Linux ]] || die 'This script requires Linux.'
[[ $EUID -eq 0 ]] || die 'Please run: sudo bash deploy.sh [port]'
[[ -s deploy/web/index.html && -d deploy/web/assets && -f deploy/nginx.conf ]] || die 'Upload the complete deployment package, including deploy/web.'
command -v systemctl >/dev/null || die 'A systemd-based Linux server is required.'
[[ ! -e /etc/nginx/conf.d/remake.conf && ! -e /var/www/remake ]] || die 'Deployment already exists: /etc/nginx/conf.d/remake.conf or /var/www/remake. Back it up before redeploying.'

echo '[1/3] Checking Nginx and system tools...'
if command -v nginx >/dev/null && command -v curl >/dev/null && command -v ss >/dev/null; then
    echo 'Dependencies already installed; skipping package downloads.'
elif command -v apt-get >/dev/null; then
    apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get install -y nginx curl ca-certificates iproute2
elif command -v dnf >/dev/null; then
    dnf install -y nginx curl ca-certificates iproute
else
    die 'Supported package managers: apt-get (Ubuntu/Debian), dnf (Rocky/AlmaLinux/Fedora).'
fi
[[ -z $(ss -H -ltn "sport = :$port") ]] || die "TCP port $port is already in use. Choose an unused port."

echo '[2/3] Publishing prebuilt web assets and configuring Nginx...'
mkdir -p /var/www /etc/nginx/conf.d
cp -R deploy/web /var/www/remake
chmod -R a+rX /var/www/remake
if command -v restorecon >/dev/null; then
    restorecon -R /var/www/remake
fi
# SELinux distributions may require an explicit label for a custom HTTP port.
if command -v getenforce >/dev/null && [[ $(getenforce) == Enforcing ]]; then
    if ! command -v semanage >/dev/null; then
        dnf install -y policycoreutils-python-utils
    fi
    if ! semanage port -l | awk '$1 == "http_port_t" {for(i=3;i<=NF;i++) {gsub(/,/, "", $i); print $i}}' | grep -qx "$port"; then
        semanage port -a -t http_port_t -p tcp "$port" 2>/dev/null || semanage port -m -t http_port_t -p tcp "$port"
    fi
fi
sed "s/__PORT__/$port/g" deploy/nginx.conf > /etc/nginx/conf.d/remake.conf
if ! nginx -t; then
    rm -f /etc/nginx/conf.d/remake.conf
    die 'Nginx configuration check failed. Existing service was not reloaded; built files remain in /var/www/remake.'
fi
systemctl enable --now nginx
systemctl reload nginx

echo '[3/3] Checking HTTP service...'
curl --fail --silent --show-error --retry 3 --retry-connrefused "http://127.0.0.1:$port/healthz"
echo "Deployment ready: http://<server-ip>:$port"
echo "Allow TCP port $port in your firewall and cloud security group."
echo 'Nginx starts automatically at boot. No build tools or automatic updates are required.'
