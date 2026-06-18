{
  config,
  lib,
  pkgs,
  helpers,
  ...
}: let
  cfg = config.my.programs.opencode;

  ocw = helpers.scriptToPackage {
    name = "ocw";
    file = ./scripts/ocw.sh;
    runtimeInputs = [pkgs.openssl pkgs.opencode];
  };

  # Dev-tools modules contribute LSP entries with lib.mkDefault so user config
  # can override them. lib.types.attrs does not resolve sub-attr priority wrappers,
  # so mkDefault leaks into the JSON without this unwrapping step.
  stripModuleWrappers = value:
    if lib.isAttrs value
    then
      if value ? _type && value._type == "override"
      then stripModuleWrappers value.content
      else lib.mapAttrs (_: stripModuleWrappers) value
    else value;

  mainConfigAttrs =
    lib.filterAttrs (_: v: v != null) {
      inherit (cfg) model small_model autoupdate share default_agent;
    }
    // lib.optionalAttrs (cfg.agents != {}) {
      agent = cfg.agents;
    }
    // lib.optionalAttrs (cfg.lsp != {}) {
      lsp = stripModuleWrappers cfg.lsp;
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

    lsp = lib.mkOption {
      type = lib.types.attrs;
      default = {};
      description = "LSP server configuration";
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      home.packages = [pkgs.opencode ocw];
      home.sessionVariables.OPENCODE_DISABLE_LSP_DOWNLOAD = "true";
    }

    (lib.mkIf (mainConfigAttrs != {}) {
      xdg.configFile."opencode/opencode.json".text = builtins.toJSON mainConfigAttrs;
    })

    (lib.mkIf (tuiConfigAttrs != {}) {
      xdg.configFile."opencode/tui.json".text = builtins.toJSON tuiConfigAttrs;
    })
  ]);
}
