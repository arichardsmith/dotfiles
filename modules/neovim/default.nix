{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.programs.neovim;

  renderFiletypeFormatter = value:
    if builtins.isList value
    then
      lib.generators.mkLuaInline (
        "{ "
        + lib.concatStringsSep ", " (map (name: lib.generators.toLua {} name) value)
        + " }"
      )
    else
      let
        formatterList =
          "{ "
          + lib.concatStringsSep ", " (map (name: lib.generators.toLua {} name) value.formatters)
          + lib.optionalString value.stop_after_first ", stop_after_first = true"
          + lib.optionalString (value.lsp_format != null) (
            ", lsp_format = " + lib.generators.toLua {} value.lsp_format
          )
          + " }";
      in lib.generators.mkLuaInline formatterList;

  byFt = lib.mapAttrs (_: renderFiletypeFormatter) cfg.conform.formatters_by_ft;

  conformLua = lib.generators.toLua {} {
    formatters_by_ft = byFt;
  };
in {
  options.programs.neovim.conform = {
    formatters_by_ft = lib.mkOption {
      type = with lib.types;
        attrsOf (either (listOf str) (submodule {
          options = {
            formatters = lib.mkOption {
              type = listOf str;
            };

            stop_after_first = lib.mkOption {
              type = bool;
              default = false;
            };

            lsp_format = lib.mkOption {
              type = nullOr (enum ["never" "fallback" "prefer" "first" "last"]);
              default = null;
            };
          };
        }));
      default = {};
      description = "Map of filetype to formatters.";
    };
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
