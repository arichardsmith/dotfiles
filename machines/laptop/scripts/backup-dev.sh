#!/usr/bin/env zsh
set -e
set -u
set -a

RESTIC_PASSWORD_COMMAND="security find-generic-password -a $USER -s restic-nas -w"
RESTIC_REPOSITORY=/Volumes/Backup/dev
RESTIC_CACHE_DIR=/Users/richardsmith/.cache/restic-backups

restic backup \
--exclude node_modules \
--exclude .direnv \
--exclude .venv \
--exclude dist \
--exclude .DS_Store \
--exclude .turbo \
~/dev/proj \
~/dev/env
