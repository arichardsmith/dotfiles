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

  installSharedSkills = config.my.programs.opencode.enable;

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

  };

  config = lib.mkMerge [
    (lib.mkIf config.programs.claude-code.enable {
      programs.claude-code = {
        context = memoryText;
        skills = allSkills;
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
