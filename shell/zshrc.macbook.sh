# --- zsh ---
# Path to oh-my-zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Add wisely, as too many plugins slow down shell startup
plugins=(git zsh-autosuggestions)

source $ZSH/oh-my-zsh.sh

# --- Config ---
# Path to oh-my-zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Local config directory
export CLI_APPS="$HOME/.cliapps"
export SHELL_CONFIG="$HOME/.config/zshh"
export OMP_THEME="catppuccin-remix"

# --- Shared config ---
source $SHELL_CONFIG/zshrc.shared.sh

# --- Mac only tools ---
source $SHELL_CONFIG/aliases/mac.sh

eval $(thefuck --alias)

autoload -U compinit; compinit

export LLAMA_EDITOR=code

eval "$(fzf --zsh)"

# Go binary tools
export PATH=$PATH:$HOME/go/bin

# --- Environment junk ---

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# pyenv
if command -v pyenv 1>/dev/null 2>&1; then
    eval "$(pyenv init -)"
fi

# Ensure apps can find the collima docker daemon
export DOCKER_HOST="unix://$HOME/.colima/docker.sock"

# Created by `pipx` on 2023-03-20 00:54:12
export PATH="$PATH:$HOME/.local/bin"

# pnpm
export PNPM_HOME="/Users/richardsmith/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
