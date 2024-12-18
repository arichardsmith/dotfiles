local opt = vim.opt
local o = vim.o
local api = vim.api
local cmd = vim.cmd

-- Silence deprecation warnings
vim.deprecate = function() end

-- keybindings
vim.g.mapleader = " "

vim.keymap.set("n", "j", 'v:count == 0 ? "gj" : "j"', { noremap = true, expr = true }) -- make navigating work as expected with wrapped lines
vim.keymap.set("n", "k", 'v:count == 0 ? "gk" : "k"', { noremap = true, expr = true }) -- make navigating work as expected with wrapped lines

vim.keymap.set("n", "H", "g^", { desc = "Jump to start of line" })
vim.keymap.set("n", "L", "g$", { desc = "Jump to end of line" })
vim.keymap.set("n", "<c-j>", "<c-e>", { desc = "Scroll down without moving cursor" })
vim.keymap.set("n", "<c-k>", "<c-y>", { desc = "Scroll up without moving cursor" })
vim.keymap.set(
	"n", 
	"<c-d>",
	":vsplit<cr>:bp<cr>:winc l<cr>",
	{ desc = "open current buffer in a split pane, switch current pane to previous buffer then focus the new pan>" }
) -- open current buffer in a split pane, switch current pane to previous buffer then focus the new pane
vim.keymap.set("n", "<leader>fmt", ":Format<cr>")
vim.keymap.set("n", "\\", ":nohl<cr>") -- quickly hide highlighted text after search
vim.keymap.set("n", ";", ":lua vim.lsp.buf.hover()<cr>") -- shortcut to show info about token at cursor
vim.keymap.set("n", "<leader>;", ':lua vim.diagnostic.open_float(0, {scope="line"})<cr>') -- shortcut to show full error message from current line
vim.keymap.set("n", "<leader>[", ":NvimTreeToggle<cr>")
vim.keymap.set("n", "<leader>o", "o<esc>") -- shortcut to create new line from normal mode
vim.keymap.set("n", "<leader>O", "O<esc>")
vim.keymap.set("n", ",", "g$a,<esc>")
vim.keymap.set("n", "<c-s>", ":w<cr>", { desc = "Save files with ctrl-s" })
vim.keymap.set("n", "<c-s><c-s>", ":w<cr>:bd<cr>", { desc = "Save files with ctrl-s" })
vim.keymap.set("i", "<c-s>", "<esc>:w<cr>a", { desc = "Save files with ctrl-s" })
vim.keymap.set("n", "<leader>bp", ":bp<cr>", { desc = "Save a shift press to switch to last buffer" })
vim.keymap.set("n", "<leader>e", ":e ", { desc = "Save a shift press when selecting a file to edit" })
vim.keymap.set("n", "<leader>r", ":e %:h/", { desc = "Quickly open [r]elative file" })
vim.keymap.set("n", "<leader>gs", ":Git<cr>5j", { desc = "Interactive [g]it [s]tatus" })
vim.keymap.set("n", "<leader>gc", ":Git commit<cr>", { desc = "[G]it [c]ommit" })
vim.keymap.set("n", "<leader>grb", ":Git rebase --interactive --autosquash ", { desc = "[G]it interactive [r]ebase" })

-- commands
-- reload the theme
api.nvim_create_user_command("ReloadTheme", function()
	cmd([[Lazy reload tokyonight.nvim]])
	cmd([[colorscheme tokyonight]])
end, {})

-- wrapping
opt.textwidth = 120 -- after configured number of characters, wrap line

-- tabs
opt.smarttab = true -- tab respects 'tabstop', 'shiftwidth', and 'softtabstop'
opt.tabstop = 2 -- the visible width of tabs
opt.softtabstop = 2 -- edit as if the tabs are 4 characters wide
opt.shiftwidth = 2 -- number of spaces to use for indent and unindent

-- searching
opt.ignorecase = true -- case insensitive searching
opt.smartcase = true -- case-sensitive if expression contains a capital letter
opt.hlsearch = true -- highlight search results
opt.incsearch = true -- set incremental search, like modern browsers

-- colours
o.termguicolors = true

-- numbers
opt.number = true -- show line numbers
opt.relativenumber = true
opt.signcolumn = "yes:1"

-- other
opt.backspace = { "indent", "eol,start" } -- make backspace behave in a sane manner
opt.mouse = "a"
opt.title = true -- set terminal title
opt.fcs = "eob: " -- hide the ~ character on empty lines at the end of the buffer
-- DISABLED due to it messing up fuzzy finding - opt.autochdir = true - change the working directory to match active file

-- highlight on yank
local highlight_group = vim.api.nvim_create_augroup("YankHighlight", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		vim.highlight.on_yank()
	end,
	group = highlight_group,
	pattern = "*",
})

-- plugins
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup("plugins")

cmd([[colorscheme catppuccin-macchiato]])
cmd([[syntax on]])
cmd([[filetype plugin indent on]])
