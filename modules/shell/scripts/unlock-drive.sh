#!/usr/bin/env zsh
set -e  # Exit immediately if any command fails
set -u  # Exit if referencing undefined variables

SERVICE_NAME="TimeMachineDrive"
DRIVE_NAME="Time Machine"
PASSPHRASE=$(security find-generic-password -a "$USER" -s "$SERVICE_NAME" -w)
echo "$PASSPHRASE" | diskutil apfs unlockVolume "$DRIVE_NAME" -stdinpassphrase
