# --- omp ---
if [ "$TERM_PROGRAM" != "Apple_Terminal" ]; then
  eval "$(oh-my-posh init zsh --config $SHELL_CONFIG/omp-themes/$OMP_THEME.toml)"
fi

# --- custom commands and apps ---
source $SHELL_CONFIG/aliases/shared.sh
export PATH="$CLI_APPS:$PATH"
export PATH="$SHELL_CONFIG/scripts:$PATH"

# --- fzf ---
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
