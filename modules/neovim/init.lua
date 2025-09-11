local opt = vim.opt
local o = vim.o
local keymap = vim.keymap

-- Silence deprecation warnings
-- vim.deprecate = function() end

-- keybindings
vim.g.mapleader = " "

keymap.set("n", "j", 'v:count == 0 ? "gj" : "j"', { noremap = true, expr = true }) -- make navigating work as expected with wrapped lines
keymap.set("n", "k", 'v:count == 0 ? "gk" : "k"', { noremap = true, expr = true }) -- make navigating work as expected with wrapped lines

keymap.set("n", "<c-j>", "<c-e>", { desc = "Scroll down without moving cursor" })
keymap.set("n", "<c-k>", "<c-y>", { desc = "Scroll up without moving cursor" })
keymap.set(
	"n",
	"<c-d>",
	":vsplit<cr>:bp<cr>:winc l<cr>",
	{ desc = "open current buffer in a split pane, switch current pane to previous buffer then focus the new pane" }
)
keymap.set("n", "\\", ":nohl<cr>", { desc = "Quickly hide highlighted text after search" })
keymap.set("n", "<leader>o", "o<esc>") -- shortcut to create new line from normal mode
keymap.set("n", "<leader>O", "O<esc>")
keymap.set("n", "<c-s>", ":w<cr>", { desc = "Save files with ctrl-s" })
keymap.set("n", "<leader>bp", ":bp<cr>", { desc = "Save a shift press to switch to last buffer" })

-- wrapping
opt.textwidth = 120 -- after configured number of characters, wrap line

-- tabs
opt.smarttab = true -- tab respects 'tabstop', 'shiftwidth', and 'softtabstop'
opt.tabstop = 2     -- the visible width of tabs
opt.softtabstop = 2 -- edit as if the tabs are 2 characters wide
opt.shiftwidth = 2  -- number of spaces to use for indent and unindent

-- searching
opt.ignorecase = true -- case insensitive searching
opt.smartcase = true  -- case-sensitive if expression contains a capital letter
opt.hlsearch = true   -- highlight search results
opt.incsearch = true  -- set incremental search, like modern browsers

-- colours
o.termguicolors = true

-- numbers
opt.number = true -- show line numbers
opt.relativenumber = true
opt.signcolumn = "yes:1"

-- other
opt.backspace = { "indent", "eol", "start" } -- make backspace behave in a sane manner
opt.mouse = "a"
opt.title = true                             -- set terminal title
opt.fcs = "eob: "                            -- hide the ~ character on empty lines at the end of the buffer
-- DISABLED due to it messing up fuzzy finding - opt.autochdir = true - change the working directory to match active file

-- Treesitter configuration
require('nvim-treesitter.configs').setup({
	highlight = { 
		enable = true, 
		use_languagetree = true 
	},
	incremental_selection = {
		enable = true,
		keymaps = {
			init_selection = "gnn",
			node_incremental = "grn",
			scope_incremental = "grc",
			node_decremental = "grm",
		},
	},
	context_commentstring = { 
		enable = true 
	},
	indent = { 
		enable = true 
	},
	rainbow = { 
		enable = true, 
		extended_mode = true, 
		max_file_lines = 1000 
	},
})
