{lib, pkgs, config, ...}: let
  cfg = config.programs.neovim;

  byFt = lib.mapAttrs (_: f: [f.name]) cfg.formatters;

  formatterDefs = lib.listToAttrs (lib.mapAttrsToList (_: f:
    lib.nameValuePair f.name (
      {command = if f.exeName != null then lib.getExe' f.package f.exeName else lib.getExe f.package;}
      // lib.optionalAttrs (f.args != null) {args = f.args;}
    )) cfg.formatters);

  conformLua = lib.generators.toLua {} {
    formatters_by_ft = byFt;
    formatters = formatterDefs;
  };
in {
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

          exeName = lib.mkOption {
            type = nullOr str;
            default = null;
            description = "Executable name within the package. Uses lib.getExe by default.";
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
				nvim-treesitter.withAllGrammars
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
