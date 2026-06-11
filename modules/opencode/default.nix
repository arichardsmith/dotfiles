{ config, lib, pkgs, ... }:
let
  cfg = config.my.programs.opencode;

  mainConfigAttrs =
    lib.filterAttrs (_: v: v != null) {
      inherit (cfg) model small_model autoupdate share default_agent;
    }
    // lib.optionalAttrs (cfg.agents != {}) {
      agent = cfg.agents;
    };

  tuiConfigAttrs = lib.filterAttrs (_: v: v != null) {
    inherit (cfg) theme;
  };
in {
  options.my.programs.opencode = {
    enable = lib.mkEnableOption "OpenCode";

    model = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Primary LLM model";
    };

    small_model = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Lightweight model for tasks like title generation";
    };

    autoupdate = lib.mkOption {
      type = lib.types.nullOr (lib.types.either lib.types.bool lib.types.str);
      default = null;
      description = "Auto-update behaviour: true, false, or \"notify\"";
    };

    share = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Sharing mode: \"manual\", \"auto\", or \"disabled\"";
    };

    default_agent = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Default agent when none specified";
    };

    theme = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "UI theme (e.g. \"system\", \"tokyonight\")";
    };

    agents = lib.mkOption {
      type = lib.types.attrs;
      default = {};
      description = "Custom agent definitions";
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    { home.packages = [ pkgs.opencode ]; }

    (lib.mkIf (mainConfigAttrs != {}) {
      xdg.configFile."opencode/opencode.json".text = builtins.toJSON mainConfigAttrs;
    })

    (lib.mkIf (tuiConfigAttrs != {}) {
      xdg.configFile."opencode/tui.json".text = builtins.toJSON tuiConfigAttrs;
    })
  ]);
}
