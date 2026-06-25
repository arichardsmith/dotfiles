{
  config,
  pkgs,
  ...
}: {
  programs.tmux = {
    baseIndex = 1;
    clock24 = true;
    escapeTime = 0;
    historyLimit = 100000;
    keyMode = "vi";
    mouse = true;
    secureSocket = false;

    terminal = "tmux-256color";
    shell =
      if config.programs.nushell.enable
      then "${pkgs.nushell}/bin/nu"
      else "${pkgs.zsh}/bin/zsh"; # Without this, it uses the wrong zsh

    plugins = with pkgs.tmuxPlugins; [
      sensible
      catppuccin
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
      set -as terminal-features ",xterm-ghostty:RGB,extkeys"
      set -as terminal-features ",ghostty:RGB,extkeys"

      # Extended keyboard support for Ghostty / Claude Code / modern TUIs.
      set -s extended-keys always
      set -s extended-keys-format csi-u

      # Shift+Enter for Claude Code inside tmux.
      bind -n S-Enter send-keys Escape "[13;2u"

      # OSC 52 clipboard over SSH.
      set -g set-clipboard on

      # Easier splits.
      unbind '"'
      unbind %
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"

      # Reload config.
      bind r source-file ~/.config/tmux/tmux.conf \; display-message "tmux config reloaded"

      # Direct window switching.
      bind -n M-1 select-window -t 1
      bind -n M-2 select-window -t 2
      bind -n M-3 select-window -t 3

      # Pane navigation.
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      # Resize panes
      bind -r H resize-pane -L 5
      bind -r J resize-pane -D 5
      bind -r K resize-pane -U 5
      bind -r L resize-pane -R 5

      bind [ copy-mode
      bind -T copy-mode-vi v send -X begin-selection
      bind -T copy-mode-vi y send -X copy-selection-and-cancel

      # Status bar
      set -g status-position top
      set -g status-left " #S "
      set -g window-status-format " #{window_index}:#{window_name} "
      set -g window-status-current-format " #{window_index}:#{window_name} "
      set -g status-right " #h "
      set -g status-left-length 32
      set -g status-right-length 32
      set -g status-interval 60

      # Theming
      set -g @catppuccin_flavor "macchiato"
      set -g status-style "fg=#{E:@thm_surface_1},bg=#{E:@thm_bg}"
      set -g window-status-style "fg=#{E:@thm_surface_1},bg=#{E:@thm_bg}"
      set -g window-status-current-style "fg=#{E:@thm_pink},bg=#{E:@thm_bg}"
      set -g status-left-style "fg=#{E:@thm_bg},bg=#{E:@thm_lavender}"
      set -g status-right-style "fg=#{E:@thm_bg},bg=#{E:@thm_lavender}"
      set -g status-left "#{?client_prefix,#[fg=#{E:@thm_bg}#,bg=#{E:@thm_mauve}],#[fg=#{E:@thm_mauve}#,bg=#{E:@thm_bg}]} #S "
    '';
  };
}
