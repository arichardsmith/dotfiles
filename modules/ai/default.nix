{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.my.ai;

  defaultContext = [
    ''
      Primary languages: TypeScript, CSS, Rust, Python, Go. Default to these but can work with others. When explaining other languages, use examples from primary languages.
      I prefer TOML for configuration. Svelte is my preferred UI framework. I prefer to use CSS rather than tailwind.
    ''
  ];

  defaultSkills = {
    go-conventions = ../../skills/go-conventions;
    nix-conventions = ../../skills/nix-conventions;
    process-feedback = ../../skills/process-feedback;
    python-conventions = ../../skills/python-conventions;
    rust-conventions = ../../skills/rust-conventions;
    rust-error-handling = ../../skills/rust-error-handling;
    svelte-conventions = ../../skills/svelte-conventions;
    typescript-conventions = ../../skills/typescript-conventions;
  };

  allSkills = defaultSkills // cfg.skills;

  memoryText = lib.concatStringsSep "\n" (defaultContext ++ cfg.context.chunks) + "\n";

  opencodeMainConfigAttrs =
    lib.filterAttrs (n: v: v != null) {
      inherit (cfg.opencode) model small_model autoupdate share default_agent;
    }
    // lib.optionalAttrs (cfg.opencode.agents != {}) {
      agent = cfg.opencode.agents;
    };

  opencodeMainConfigJson =
    if opencodeMainConfigAttrs != {}
    then builtins.toJSON opencodeMainConfigAttrs
    else null;

  opencodeTuiConfigAttrs = lib.filterAttrs (n: v: v != null) {
    inherit (cfg.opencode) theme;
  };

  opencodeTuiConfigJson =
    if opencodeTuiConfigAttrs != {}
    then builtins.toJSON opencodeTuiConfigAttrs
    else null;

  installSharedSkills = cfg.opencode.enable;

  sharedSkillConfigs = lib.mapAttrs' (name: path:
    lib.nameValuePair ".agents/skills/${name}" {
      source = path;
      recursive = true;
    })
  allSkills;

  codexSkillSyncCommands = lib.concatStringsSep "\n" (
    lib.mapAttrsToList (name: _path: ''
      $DRY_RUN_CMD rm -rf "$HOME/.codex/skills/${name}"
      $DRY_RUN_CMD mkdir -p "$HOME/.codex/skills/${name}"
      $DRY_RUN_CMD ${pkgs.rsync}/bin/rsync -aL --delete \
        "$HOME/.agents/skills/${name}/" \
        "$HOME/.codex/skills/${name}/"
    '')
    allSkills
  );
in {
  options.my.ai = {
    context.chunks = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Text chunks to add to AI agent memory";
    };

    skills = lib.mkOption {
      type = lib.types.attrsOf lib.types.path;
      default = {};
      description = "Additional skill directories to include beyond the defaults";
      example = lib.literalExpression ''
        {
          custom-skill = ./custom-skill;
          project-conventions = ./project-conventions;
        }
      '';
    };

    claude-code.enable = lib.mkEnableOption "Claude Code integration";

    opencode = {
      enable = lib.mkEnableOption "OpenCode integration";

      model = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Primary LLM model to use (e.g., 'anthropic/claude-sonnet-4-5')";
      };

      small_model = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Lightweight model for tasks like title generation";
      };

      autoupdate = lib.mkOption {
        type = lib.types.nullOr (lib.types.either lib.types.bool lib.types.str);
        default = null;
        description = "Enable updates, disable, or set to 'notify' for alerts only";
      };

      share = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Sharing mode: 'manual', 'auto', or 'disabled'";
      };

      default_agent = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Default agent when none specified";
      };

      theme = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "UI theme selection (e.g., 'system', 'tokyonight')";
      };

      agents = lib.mkOption {
        type = lib.types.attrs;
        default = {};
        description = "Custom agent definitions for OpenCode";
        example = lib.literalExpression ''
          {
            plan = {
              permission = {
                skill = {
                  "internal-*" = "allow";
                };
              };
            };
            custom-agent = {
              tools = {
                skill = false;
              };
            };
          }
        '';
      };
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.claude-code.enable {
      programs.claude-code = {
        context = memoryText;
        skills = allSkills;
      };
    })

    (lib.mkIf cfg.opencode.enable {
      # The package is currently broken (needs bun 1.3.10, gets 1.3.9)
      # home.packages = [pkgs.opencode];

      home.activation.installOpencode = lib.hm.dag.entryAfter ["writeBoundary"] ''
        echo "Installing OpenCode via Bun escape hatch..."
        $DRY_RUN_CMD ${pkgs.bun}/bin/bun add -g opencode-ai
      '';

      xdg.configFile."opencode/opencode.json" = lib.mkIf (opencodeMainConfigJson != null) {
        text = opencodeMainConfigJson;
      };

      xdg.configFile."opencode/tui.json" = lib.mkIf (opencodeTuiConfigJson != null) {
        text = opencodeTuiConfigJson;
      };
    })

    (lib.mkIf installSharedSkills {
      home.file = sharedSkillConfigs;
    })

    (lib.mkIf config.programs.codex.enable {
      home.activation.syncCodexSkills = lib.hm.dag.entryAfter ["writeBoundary"] ''
        $DRY_RUN_CMD mkdir -p "$HOME/.codex/skills"
        ${codexSkillSyncCommands}
      '';
    })
  ];
}
