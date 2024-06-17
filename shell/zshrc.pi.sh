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