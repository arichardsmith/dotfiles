return {
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
		config = function ()
			require("tokyonight").setup({
				style = "moon",
				on_colors = function (colors)
					-- make the theme a bit closer to "Snazzy" by Sindre Sorhus
					colors.purple = "#ff6ac1"
					colors.cyan = "#9aedfe"
					colors.blue = "#57c7ff"
				end,
				on_highlights = function (highlights, colors)
					highlights["@property.javascript"] = {
						fg = colors.blue6
					}
					
					highlights["@property.typescript"] = {
						link = "@property.javascript"
					}

					highlights["@property.scss"] = {
						fg = colors.fg
					}

					highlights["@selector.class.scss"] = {
						fg = colors.green
					}

					highlights["@selector.pseudo.scss"] = {
						fg = colors.magenta
					}

					highlights["@include.scss"] = {
						link = "@keyword.scss"
					}

					highlights["@function.scss"] = {
						link = "@keyword.scss"
					}

					highlights["@tag.delimiter"] = {
						fg = colors.fg_dark
					}

					highlights["@text.svelte"] = {
						fg = colors.fg
					}

					highlights["@conditional.svelte"] = {
						link = "@keyword.svelte"
					}
					
					highlights["@tag.component.svelte"] = {
						fg = colors.orange
					}
					
				end
			})
		end
	}
}
