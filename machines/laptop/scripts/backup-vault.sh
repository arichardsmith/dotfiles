set -a

RESTIC_PASSWORD_COMMAND="security find-generic-password -a $USER -s restic-nas -w"
RESTIC_REPOSITORY=/Volumes/Backup/vault
RESTIC_CACHE_DIR=/Users/richardsmith/.cache/restic-backups

restic backup \
  --exclude .DS_Store \
  --exclude .trash \
  ~/Documents/Vault
