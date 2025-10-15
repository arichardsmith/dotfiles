#!/bin/zsh
SERVICE_NAME="TimeMachineDrive"
PASSPHRASE=$(security find-generic-password -a "$USER" -s "$SERVICE_NAME" -w)
echo "$PASSPHRASE" | diskutil apfs unlockVolume disk6s2 -stdinpassphrase
