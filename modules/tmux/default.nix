{pkgs, ...}: {
  programs.tmux = {
    baseIndex = 1;
    clock24 = true;
    escapeTime = 0;
    historyLimit = 100000;
    keyMode = "vi";
    mouse = true;
    secureSocket = false;

    terminal = "tmux-256color";

    plugins = with pkgs.tmuxPlugins; [
      sensible
      yank
      vim-tmux-navigator
    ];

    extraConfig = ''
      set -g renumber-windows on
      set -g focus-events on
      set -g detach-on-destroy off
      set -g allow-passthrough on

      # Use Ctrl+a as prefix
      unbind C-b

      set -g prefix C-a
      bind C-a send-prefix

      # True colour / modern terminal support.
      set -as terminal-features ",xterm-256color:RGB"
      set -as terminal-features ",tmux-256color:RGB"

      # OSC 52 clipboard over SSH.
      set -g set-clipboard on

      # Easier splits.
      unbind '"'
      unbind %
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"

      # Reload config.
      bind r source-file ~/.config/tmux/tmux.conf \; display-message "tmux config reloaded"

      # Pane navigation.
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      bind [ copy-mode
      bind -T copy-mode-vi v send -X begin-selection
      bind -T copy-mode-vi y send -X copy-selection-and-cancel

      # Status bar
      set -g status-position bottom
      set -g status-left "#S "
      set -g window-status-format "#{window_index}:#{window_name} "
      set -g window-status-current-format "[#{window_index}:#{window_name}] "
      set -g status-right "#h"
      set -g status-left-length 32
      set -g status-right-length 32
      set -g status-interval 60
    '';
  };
}
