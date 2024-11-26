return {
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		dependencies = {
			-- show treesitter nodes
			"nvim-treesitter/playground",
			"nvim-treesitter/nvim-treesitter-textobjects", -- enable more advanced treesitter-aware text objects
		},
		opts = {
			ensure_installed = {
				"bash",
				"css",
				"diff",
				"comment",
				"git_rebase",
				"gitcommit",
				"gitignore",
				"go",
				"html",
				"javascript",
				"jsdoc",
				"json",
				"json",
				"json5",
				"jsonc",
				"lua",
				"markdown",
				"markdown_inline",
				"prisma",
				"python",
				"rust",
				"scss", -- needed for postcss highlighting 🤷
				"svelte",
				"typescript",
				"tsx",
				"vim",
				"yaml",
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
			highlight = { enable = true, use_languagetree = true },
			context_commentstring = { enable = true },
			indent = { enable = true },
			rainbow = { enable = true, extended_mode = true, max_file_lines = 1000 },
		},
		config = function(_, opts)
			require("nvim-treesitter.configs").setup(opts)
		end,
	},
}
