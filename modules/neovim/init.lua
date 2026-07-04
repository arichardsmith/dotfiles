-- ============================================================
-- Leader
-- ============================================================

-- Set before any plugin loads so mappings pick it up correctly.
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- ============================================================
-- Options
-- ============================================================

local opt = vim.opt
opt.number = true
opt.relativenumber = false
opt.signcolumn = "yes:1"  -- Always show; "yes:1" reserves exactly one column so the layout never shifts
opt.laststatus = 3        -- Single global statusline (Neovim 0.7+); without this each split gets its own
opt.wrap = true
opt.linebreak = true      -- Wrap at word boundaries instead of mid-word
opt.textwidth = 120
opt.smarttab = true
opt.tabstop = 2
opt.softtabstop = 2
opt.shiftwidth = 2
opt.ignorecase = true
opt.smartcase = true      -- Override ignorecase when the pattern contains an uppercase letter
opt.hlsearch = true
opt.incsearch = true
opt.backspace = {"indent", "eol", "start"}
opt.mouse = "a"
opt.title = true
opt.exrc = true           -- Load a .nvim.lua / .exrc file from the working directory for per-project config
opt.termguicolors = true

-- ============================================================
-- Keymaps
-- ============================================================

local map = vim.keymap.set

local telescope = require("telescope")
telescope.setup({
  extensions = {
    file_browser = {
      grouped = true,
      hidden = true,
      respect_gitignore = false,
      select_buffer = true,
    },
  },
})
telescope.load_extension("file_browser")

map("n", "<leader>f", "<cmd>Telescope find_files<cr>", {desc = "Find files"})
map("n", "<leader>b", "<cmd>Telescope buffers<cr>", {desc = "Buffers"})
map("n", "<leader>g", "<cmd>Telescope git_status<cr>", {desc = "Changed files"})

map("n", "<leader>e", function()
  local dir = vim.fn.expand("%:p:h")
  if dir == "" then
    dir = vim.fn.getcwd()
  end

  telescope.extensions.file_browser.file_browser({
    cwd = dir,
    hidden = true,
    path = dir,
    respect_gitignore = false,
  })
end, {desc = "Browse buffer dir"})

map("n", "<leader>/", "<cmd>Telescope live_grep<cr>", {desc = "Search project"})
map({"n", "x"}, "<leader>y", '"+y', {desc = "Yank to system clipboard"})
map("n", "<leader>k", vim.lsp.buf.hover, {desc = "Hover / symbol info"})
map("n", "<leader>K", "<cmd>Trouble diagnostics toggle<cr>", {desc = "Toggle diagnostics panel"})
map("n", "<leader>r", vim.lsp.buf.rename, {desc = "LSP rename symbol"})
map("n", "<leader>h", vim.lsp.buf.references, {desc = "Symbol references"})
map("n", "<leader>n", "<C-i>", {desc = "Jump forward"})
map("n", "<leader>N", "<C-o>", {desc = "Jump backward"})
map("n", "<leader>m", "<C-o>", {desc = "Jump backward"})

-- Go to
map("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })

map("n", "\\d", function()
  local file = vim.api.nvim_buf_get_name(0)
  if file ~= "" then
    vim.fn.delete(file)
  end
end, {desc = "Delete current file"})

map("n", "\\D", function()
  local file = vim.api.nvim_buf_get_name(0)
  if file ~= "" then
    vim.fn.delete(file)
    vim.cmd("bdelete!")
  end
end, {desc = "Delete file and close buffer"})

map("n", "\\f", function()
  require("conform").format({lsp_format = "fallback"})
end, {desc = "Format buffer"})

map("n", "\\y", 'gg"+yG', {desc = "Yank whole file to clipboard"})

map("n", "\\w", "<cmd>setlocal wrap!<cr>", {desc = "Toggle line wrap"})

-- Don't close the selection after changing indentation in visual mode
vim.keymap.set("v", ">", ">gv")
vim.keymap.set("v", "<", "<gv")

-- ============================================================
-- Colorscheme
-- ============================================================

require("catppuccin").setup({flavour = "mocha"})
vim.cmd.colorscheme("catppuccin-mocha")
-- Link the statusline highlight groups to Normal so the bar blends into the
-- background rather than rendering with a distinct bar color.
vim.api.nvim_set_hl(0, "StatusLine", {link = "Normal"})
vim.api.nvim_set_hl(0, "StatusLineNC", {link = "Normal"})

-- ============================================================
-- Plugins
-- ============================================================

-- nvim-surround: add/change/delete surrounding pairs (brackets, quotes, tags…)
require("nvim-surround").setup({
})

-- which-key: shows a popup of available keybindings after a short delay
require("which-key").setup({
	preset = "helix"
})

-- nvim-autopairs: automatically inserts the closing bracket/quote/etc.
require("nvim-autopairs").setup({
})

-- trouble.nvim: pretty list for diagnostics, references, quickfix, etc.
require("trouble").setup({})

-- blink.cmp: completion engine
-- prefer_rust_with_warning uses the faster Rust fuzzy matcher when available,
-- falling back to the Lua implementation with a one-time console warning.
require("blink.cmp").setup({
  keymap = {
    preset = "default",
    ["<CR>"] = { "accept", "fallback" },
    ["<Tab>"] = { "accept", "fallback" },
    ["<C-j>"] = { "select_next", "fallback" },
    ["<C-k>"] = { "select_prev", "fallback" },
    ["<S-Tab>"] = { "select_prev", "fallback" },
  },
  sources = {
    default = {"lsp", "path", "snippets", "buffer"},
  },
  fuzzy = {implementation = "prefer_rust_with_warning"},
  signature = {enabled = true},
  cmdline = {
    enabled = true,
    keymap = {
      preset = "inherit",
      ["<CR>"] = { "fallback" },
    },
    completion = {menu = {auto_show = true}},
  },
})

-- ============================================================
-- Autocmds
-- ============================================================

-- Attempt to start Treesitter highlighting for every filetype. pcall swallows
-- the error silently when no parser is installed for that language.
vim.api.nvim_create_autocmd("FileType", {
  callback = function()
    pcall(vim.treesitter.start)
  end,
})

-- Reload files changed outside Neovim. Skipped in command-line mode because
-- checktime is not safe to call there.
vim.api.nvim_create_autocmd({"FocusGained", "BufEnter", "CursorHold", "CursorHoldI"}, {
  callback = function()
    if vim.fn.mode() ~= "c" then
      vim.cmd("checktime")
    end
  end,
})

-- Track whether the on-disk version differs from what was last read/written.
-- When the buffer has unsaved changes we can't safely auto-reload, so instead
-- we set source_changed = true and suppress the default prompt (fcs_choice = "").
-- The statusline uses this flag to show the "[-]" staleness indicator.
vim.api.nvim_create_autocmd("FileChangedShell", {
  callback = function(args)
    if vim.bo[args.buf].modified then
      vim.b[args.buf].source_changed = true
      vim.v.fcs_choice = ""
    else
      vim.v.fcs_choice = "reload"
    end
  end,
})

-- Clear the staleness flag after the buffer is synced with disk.
vim.api.nvim_create_autocmd({"BufReadPost", "BufWritePost"}, {
  callback = function(args)
    vim.b[args.buf].source_changed = false
  end,
})

-- ============================================================
-- Statusline
-- ============================================================

local mode_names = {
  n = "NOR",
  i = "INS",
  v = "VIS",
  V = "VLN",
  ["\22"] = "VBLK",  -- Ctrl-V visual block mode; \22 is the ASCII code for ^V
  c = "CMD",
  R = "REP",
  s = "SEL",
  S = "SLN",
  t = "TRM",
}

-- Returns a short indicator reflecting unsaved / stale state:
--   [+]  buffer modified (unsaved changes)
--   [-]  on-disk version is newer (file changed externally, buffer unmodified)
--   [!]  both: unsaved changes AND the disk version has since changed
local function edit_status()
  local modified = vim.bo.modified
  local on_disk = vim.b.source_changed == true
  if modified and on_disk then
    return "[!]"
  elseif modified then
    return "[+]"
  elseif on_disk then
    return "[-]"
  end

  return ""
end

-- Called on every statusline redraw via the %!v:lua.statusline() expression below.
function _G.statusline()
  local mode = mode_names[vim.fn.mode()] or vim.fn.mode()
  -- %:. produces a path relative to cwd, which is shorter than the full path
  local name = vim.fn.expand("%:.")
  if name == "" then
    name = "[No Name]"
  end

  return string.format(" %s  %s %s", mode, name, edit_status())
end

-- %! tells Neovim to evaluate the expression and use the result as the statusline string.
vim.o.statusline = "%!v:lua.statusline()"
-- ModeChanged doesn't trigger a statusline redraw by default, so force one.
vim.api.nvim_create_autocmd("ModeChanged", {command = "redrawstatus"})

-- ============================================================
-- LSP
-- ============================================================

-- Attach blink.cmp's extended capabilities to every LSP server so completion
-- gets richer information (e.g. snippet support, resolve capabilities).
vim.lsp.config("*", {capabilities = require("blink.cmp").get_lsp_capabilities()})

-- ============================================================
-- User commands
-- ============================================================

vim.api.nvim_create_user_command("ReloadConfig", function()
  vim.cmd("source $MYVIMRC")
end, {desc = "Re-source config"})

vim.api.nvim_create_user_command("Fmt", function()
  require("conform").format({lsp_format = "fallback"})
end, {desc = "Format buffer"})

vim.api.nvim_create_user_command("Bc", function()
  vim.cmd("bdelete")
end, {desc = "Close current buffer"})

vim.api.nvim_create_user_command("Bca", function()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) then
      vim.api.nvim_buf_delete(buf, {force = false})
    end
  end
end, {desc = "Close all buffers"})

vim.api.nvim_create_user_command("Bco", function()
  local current = vim.api.nvim_get_current_buf()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if buf ~= current and vim.api.nvim_buf_is_loaded(buf) then
      vim.api.nvim_buf_delete(buf, {force = false})
    end
  end
end, {desc = "Close all buffers except current"})
