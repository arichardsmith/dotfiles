{
  lib,
  pkgs,
  config,
  helpers,
  ...
}: let
  cfg = config.programs.neovim;
  formatterOverrideType = with lib.types;
    submodule {
      freeformType = anything;

      options = {
        "inherit" = lib.mkOption {
          type = nullOr (either bool str);
          default = null;
        };

        command = lib.mkOption {
          type = nullOr anything;
          default = null;
        };

        cwd = lib.mkOption {
          type = nullOr anything;
          default = null;
        };

        args = lib.mkOption {
          type = nullOr (either (listOf str) str);
          default = null;
        };

        prepend_args = lib.mkOption {
          type = nullOr (either (listOf str) str);
          default = null;
        };

        append_args = lib.mkOption {
          type = nullOr (either (listOf str) str);
          default = null;
        };

        stdin = lib.mkOption {
          type = nullOr bool;
          default = null;
        };

        tmpfile_format = lib.mkOption {
          type = nullOr str;
          default = null;
        };

        condition = lib.mkOption {
          type = nullOr anything;
          default = null;
        };

        exit_codes = lib.mkOption {
          type = nullOr (listOf int);
          default = null;
        };

        env = lib.mkOption {
          type = nullOr (attrsOf anything);
          default = null;
        };

        options = lib.mkOption {
          type = nullOr (attrsOf anything);
          default = null;
        };
      };
    };

  renderFiletypeFormatter = value:
    if builtins.isList value
    then
      lib.generators.mkLuaInline (
        "{ "
        + lib.concatStringsSep ", " (map (name: lib.generators.toLua {} name) value)
        + " }"
      )
    else let
      formatterList =
        "{ "
        + lib.concatStringsSep ", " (map (name: lib.generators.toLua {} name) value.formatters)
        + lib.optionalString value.stop_after_first ", stop_after_first = true"
        + lib.optionalString (value.lsp_format != null) (
          ", lsp_format = " + lib.generators.toLua {} value.lsp_format
        )
        + " }";
    in
      lib.generators.mkLuaInline formatterList;

  byFt = lib.mapAttrs (_: renderFiletypeFormatter) cfg.conform.formatters_by_ft;

  conformLua = lib.generators.toLua {} {
    formatters = cfg.conform.formatters;
    formatters_by_ft = byFt;
  };
in {
  options.programs.neovim.conform = {
    formatters = lib.mkOption {
      type = with lib.types; attrsOf formatterOverrideType;
      default = {};
      description = "Map of formatter overrides.";
    };

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
    home.packages = [
      (helpers.uvScriptToPackage {
        name = "nvim-init";
        file = ./scripts/nvim-init.py;
        runtimeInputs = [pkgs.git];
      })
    ];

    programs.neovim = {
      plugins = with pkgs.vimPlugins; [
        catppuccin-nvim
        telescope-nvim
        telescope-file-browser-nvim
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
        trouble-nvim
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
