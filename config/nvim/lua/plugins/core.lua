return {
	{ "tpope/vim-surround", lazy = false }, -- wrap text in quotes etc
	{ "windwp/nvim-autopairs", config = true }, -- auto pair input text
	{ "windwp/nvim-ts-autotag", config = true },
	{ "tpope/vim-sleuth" }, -- automatically detect tab size
	{
		"tpope/vim-fugitive", -- git from within neovim
		lazy = false,
		dependencies = { "tpope/vim-rhubarb" },
	},
	{
		"lewis6991/gitsigns.nvim",
		opts = {
			signs = {
				add = { text = "+" },
				change = { text = "~" },
				delete = { text = "_" },
				topdelete = { text = "‾" },
				changedelete = { text = "~" },
			},
		},
	},
	{
		"sudormrfbin/cheatsheet.nvim",
		dependencies = {
			"nvim-telescope/telescope.nvim",
			"nvim-lua/popup.nvim",
			"nvim-lua/plenary.nvim",
		},
		opts = {
			bundled_cheatsheets = {
				disabled = {
					"nerd-fonts",
				},
			},
		},
	},
	{
		"folke/trouble.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
	},
	{
		"yamatsum/nvim-cursorline",
		opts = {
			cursorline = {
				enable = true,
				timeout = 1000,
				number = false,
			},
			cursorword = {
				enable = true,
				min_length = 3,
				hl = { underline = true },
			},
		},
	},
	{ "jghauser/mkdir.nvim" }, -- automatically make missing folders when saving a file
}
