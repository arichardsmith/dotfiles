return {
	{
		"nvim-lualine/lualine.nvim",
		opts = {
			options = {
				theme = "catppuccin"
			},
			sections = {
				lualine_a = { "mode" },
				lualine_b = { "branch", "diff" },
				lualine_c = { { "filename", path = 1 } },
				lualine_x = { "filetype" },
				lualine_y = { "progress" },
				lualine_z = { "location" },
			},
		},
		config = function(_, opts)
			require("lualine").setup(opts)
		end,
	},
}
