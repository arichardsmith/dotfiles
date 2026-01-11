#!/usr/bin/env bash
set -euo pipefail

# This script is necessary because home-manager cannot write files directly to /etc/
# or /etc/systemd/system/ (system-level locations require root access).
# Instead, home-manager writes config files to ~/.config/sanoid/, and this script
# creates the necessary symlinks with root privileges.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root (use sudo)"
   exit 1
fi

mkdir -p /etc/sanoid
ln -sf "${SCRIPT_DIR}/sanoid.conf" /etc/sanoid/sanoid.conf
echo "Linked sanoid.conf"

for unit in sanoid.timer sanoid.service sanoid-prune.service; do
    ln -sf "${SCRIPT_DIR}/systemd/${unit}" "/etc/systemd/system/${unit}"
    echo "Linked ${unit}"
done

systemctl daemon-reload
systemctl enable sanoid-prune.service
systemctl enable sanoid.timer
systemctl start sanoid.timer

echo "Sanoid setup complete"
systemctl status sanoid.timer --no-pager
