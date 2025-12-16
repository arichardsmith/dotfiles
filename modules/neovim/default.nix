{pkgs, ...}: {
  imports = [
    ./treesitter.nix
  ];

  programs.neovim = {
    plugins = with pkgs.vimPlugins; [
      vim-sensible
      plenary-nvim
      {
        plugin = catppuccin-nvim;
        config = "colorscheme catppuccin";
      }
      {
        plugin = lualine-nvim;
        config = "lua require('lualine').setup()";
      }
      {
        plugin = gitsigns-nvim;
        config = ''
          lua << EOF
          require('gitsigns').setup({
            signs = {
              add = { text = '+' },
              change = { text = '~' },
              delete = { text = '_' },
              topdelete = { text = '‾' },
              changedelete = { text = '~' },
            },
          })
          EOF
        '';
      }
      mkdir-nvim
      vim-sleuth
      {
        plugin = nvim-autopairs;
        config = "lua require('nvim-autopairs').setup({})";
      }
    ];

    extraLuaConfig = builtins.readFile ./init.lua;
  };
}
