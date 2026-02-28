{
  config,
  lib,
  ...
}: let
  defaultMemory = [
    ''
      Primary languages: TypeScript, CSS, Rust, Python, Go. Default to these but can work with others. When explaining other languages, use examples from primary languages.
      I prefer TOML for configuration. Svelte is my preferred UI framework. I prefer to use CSS rather than tailwind.
    ''
    ''
      For I use snake_case for variables and functions in most langauges. I use PascalCase for types and clases. I use camelCase for publicly exported values in JS/TS.
      For go, I use the idiomatic casing.
    ''
  ];

  cfg = config.programs.ai-agent;

  memoryText = lib.concatStringsSep "\n" (defaultMemory ++ cfg.memory.chunks) + "\n";
in {
  options = {
    programs.ai-agent.memory.chunks = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Text to add to the global Agents.md / Claude.md";
    };
  };

  config = {
    programs.claude-code = {
      memory.text = memoryText;
      skills = {
        cli-conventions = ./skills/cli-conventions.md;
        go-conventions = ./skills/go-conventions.md;
        nix-conventions = ./skills/nix-conventions.md;
        process-feedback = ./skills/process-feedback.md;
        python-conventions = ./skills/python-conventions.md;
        rust-conventions = ./skills/rust-conventions.md;
        rust-error-handling = ./skills/rust-error-handling.md;
        svelte-conventions = ./skills/svelte-conventions.md;
        typescript-conventions = ./skills/typescript-conventions.md;
      };
    };
  };
}
