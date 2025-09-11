{pkgs, ...}: {
  programs.neovim.plugins = with pkgs.vimPlugins; [
    {
      plugin = (nvim-treesitter.withPlugins (p: [
        p.bash
        p.css
        p.diff
        p.comment
        p.git_rebase
        p.gitcommit
        p.gitignore
        p.go
        p.html
        p.javascript
        p.jsdoc
        p.json
        p.json5
        p.jsonc
        p.lua
        p.markdown
        p.markdown_inline
        p.prisma
        p.python
        p.rust
        p.scss
        p.svelte
        p.typescript
        p.tsx
        p.vim
        p.yaml
        p.nix
        p.gleam
        p.vimdoc
      ]));
    }
  ];
}