{lib, pkgs, config, ...}: let
  cfg = config.programs.neovim;

  byFt = lib.mapAttrs (_: f: [f.name]) cfg.formatters;

  formatterDefs = lib.listToAttrs (lib.mapAttrsToList (_: f:
    lib.nameValuePair f.name (
      {command = lib.getExe f.package;}
      // lib.optionalAttrs (f.args != null) {args = f.args;}
    )) cfg.formatters);

  conformLua = lib.generators.toLua {} {
    formatters_by_ft = byFt;
    formatters = formatterDefs;
  };
in {
  imports = [
    ./treesitter.nix
    ./toolchains
  ];

  options.programs.neovim.formatters = lib.mkOption {
    type = with lib.types;
      attrsOf (submodule {
        options = {
          name = lib.mkOption {
            type = str;
            description = "conform formatter id, e.g. prettier";
          };

          package = lib.mkOption {
            type = package;
            description = "package providing the formatter binary";
          };

          args = lib.mkOption {
            type = nullOr (listOf str);
            default = null;
          };
        };
      });
    default = {};
    description = "Per-filetype external formatters.";
  };

  config = lib.mkIf cfg.enable {
    programs.neovim = {
      plugins = with pkgs.vimPlugins; [
        catppuccin-nvim
        telescope-nvim
        plenary-nvim
        nvim-web-devicons
        nvim-surround
        which-key-nvim
        blink-cmp
        friendly-snippets
        conform-nvim
        nvim-lspconfig
        gitsigns-nvim
        nvim-autopairs
      ];

      extraPackages = with pkgs; [
        ripgrep
        fd
      ];

      initLua =
        builtins.readFile ./init.lua
        + "\nrequire('conform').setup(${conformLua})\n";
    };
  };
}
