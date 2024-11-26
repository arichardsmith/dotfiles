# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# --- Config ---
export USER="/home/richardsmith"

# Local config directory
export CLI_APPS="$USER/.cliapps"
export SHELL_CONFIG="$USER/.config/zshh"
export OMP_THEME="catppuccin-remix"

# --- Shared config ---
source $SHELL_CONFIG/zshrc.shared.sh
source $SHELL_CONFIG/aliases/pi.sh

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion