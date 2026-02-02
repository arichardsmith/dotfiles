{
  config,
  lib,
  ...
}: let
  defaultMemory = [
    ''
      Primary languages: TypeScript, CSS, Rust, Go. Default to these but can work with others. When explaining other languages, use examples from primary languages. I prefer TOML for configuration. Svelte is my preferred UI framework. I prefer to use CSS rather than tailwind.
    ''
    ''
      I manage my apps and dependencies using Nix, but I do not use NixOS. When discussing Nix, answer in terms of flakes and home manager.
    ''
  ];

  cfg = config.programs.claude-code;

  memoryText = lib.concatStringsSep "\n" (defaultMemory ++ cfg.memory.chunks) + "\n";
in {
  options = {
    programs.claude-code.memory.chunks = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Text to add to the global Claude.md";
    };
  };

  config = {
    programs.claude-code = {
      enable = true;
      skillsDir = ./skills;
      memory.text = memoryText;
    };
  };
}
