{
  config,
  pkgs,
  lib,
  ...
}:
lib.helpers.mkProgram {inherit config pkgs;} "ai-agent" {
  settings = {
    # Shared configuration
    memory.chunks = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Text chunks to add to AI agent memory";
    };

    skills = lib.mkOption {
      type = lib.types.attrsOf lib.types.path;
      default = {};
      description = "Additional skill files to include beyond the defaults";
      example = lib.literalExpression ''
        {
          custom-skill = ./custom-skill.md;
          project-conventions = ./project-conventions.md;
        }
      '';
    };

    # Claude Code configuration
    claude-code.enable = lib.mkEnableOption "Claude Code integration";

    # OpenCode configuration
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

  setup = {
    pkgs,
    cfg,
    ...
  }: let
    defaultMemory = [
      ''
        Primary languages: TypeScript, CSS, Rust, Python, Go. Default to these but can work with others. When explaining other languages, use examples from primary languages.
        I prefer TOML for configuration. Svelte is my preferred UI framework. I prefer to use CSS rather than tailwind.
      ''
    ];

    # Default skills that are always included
    defaultSkills = {
      go-conventions = ./skills/go-conventions.md;
      nix-conventions = ./skills/nix-conventions.md;
      process-feedback = ./skills/process-feedback.md;
      python-conventions = ./skills/python-conventions.md;
      rust-conventions = ./skills/rust-conventions.md;
      rust-error-handling = ./skills/rust-error-handling.md;
      svelte-conventions = ./skills/svelte-conventions.md;
      typescript-conventions = ./skills/typescript-conventions.md;
    };

    # Merge default skills with user-provided skills (user skills can override defaults)
    allSkills = defaultSkills // cfg.settings.skills;

    memoryText = lib.concatStringsSep "\n" (defaultMemory ++ cfg.settings.memory.chunks) + "\n";

    # OpenCode configuration
    opencodeMainConfigAttrs =
      lib.filterAttrs (n: v: v != null) {
        inherit (cfg.settings.opencode) model small_model autoupdate share default_agent;
      }
      // lib.optionalAttrs (cfg.settings.opencode.agents != {}) {
        agent = cfg.settings.opencode.agents;
      };

    opencodeMainConfigJson =
      if opencodeMainConfigAttrs != {}
      then builtins.toJSON opencodeMainConfigAttrs
      else null;

    opencodeTuiConfigAttrs = lib.filterAttrs (n: v: v != null) {
      inherit (cfg.settings.opencode) theme;
    };

    opencodeTuiConfigJson =
      if opencodeTuiConfigAttrs != {}
      then builtins.toJSON opencodeTuiConfigAttrs
      else null;

    # Create OpenCode skill directory structure
    opencodeSkillConfigs = lib.mapAttrs' (name: path:
      lib.nameValuePair "opencode/skills/${name}/SKILL.md" {
        source = path;
      })
    allSkills;
  in
    lib.mkMerge [
      # Claude Code configuration
      (lib.mkIf cfg.settings.claude-code.enable {
        programs.claude-code = {
          memory.text = memoryText;
          skills = allSkills;
        };
      })

      # OpenCode configuration
      (lib.mkIf cfg.settings.opencode.enable {
        home.packages = [pkgs.opencode];

        xdg.configFile."opencode/opencode.json" = lib.mkIf (opencodeMainConfigJson != null) {
          text = opencodeMainConfigJson;
        };

        xdg.configFile."opencode/tui.json" = lib.mkIf (opencodeTuiConfigJson != null) {
          text = opencodeTuiConfigJson;
        };
      })

      # OpenCode skills (only if opencode is enabled)
      (lib.mkIf cfg.settings.opencode.enable {
        xdg.configFile = opencodeSkillConfigs;
      })
    ];
}
