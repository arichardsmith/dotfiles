#!/usr/bin/env bash
set -euo pipefail

# This script is necessary because home-manager cannot write systemd unit files
# directly to /etc/systemd/system/ (requires root access).
# The sanoid config file stays in ~/.config/sanoid/ and is read via the --configdir flag.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root (use sudo)"
   exit 1
fi

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
