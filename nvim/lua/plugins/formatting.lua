return {
	{
		"mhartington/formatter.nvim",
		config = function()
			require("formatter").setup({
				filetype = {
					lua = {
						require("formatter.filetypes.lua").stylua,
					},
					javascript = {
						require("formatter.filetypes.javascript").prettier,
					},
					typescrpt = {
						require("formatter.filetypes.typescript").prettier,
					},
					svelte = {
						require("formatter.filetypes.svelte").prettier,
					},
					json = {
						require("formatter.filetypes.json").jq,
					},
					css = {
						require("formatter.filetypes.css").prettier,
					},
					go = {
						require("formatter.filetypes.go").gofmt,
					},
					["*"] = {
						require("formatter.filetypes.any").remove_trailing_whitespace,
					},
				},
			})
		end,
	},
}
