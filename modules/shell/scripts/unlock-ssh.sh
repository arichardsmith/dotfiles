# Unlock the daily ssh key so we can ssh into servers without entering a password
DAILY_SSH_KEY="${DAILY_SSH_KEY:-$HOME/.ssh/daily_key}"
if ! ssh-add -l | grep -q "$(ssh-keygen -lf "$DAILY_SSH_KEY" 2>/dev/null | awk '{print $2}')"; then
  ssh-add "$DAILY_SSH_KEY"
fi
