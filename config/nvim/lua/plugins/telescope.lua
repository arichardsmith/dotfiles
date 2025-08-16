return {
	'nvim-telescope/telescope.nvim', 
	tag = '0.1.2',
	dependencies = { 'nvim-lua/plenary.nvim' },
	config = function ()
		require("telescope").setup({
			defaults = {
				pickers = {
					find_files = {
						find_command = { "fd", "--type", "f", "--hidden", "--strip-cwd-prefix" }
					}
				},
				mappings = {
					i = {
						["<Esc>"] = require("telescope.actions").close -- don't go into normal mode, just close
					}
				},
				file_ignore_patterns = { "node_modules" }
			}
		})

		local builtin = require('telescope.builtin')
		vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
		vim.keymap.set('n', '<leader>fs', builtin.git_files, {})
		vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
		vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
		vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
		if vim.fn.isdirectory(".git") then
			vim.keymap.set('n', '<leader>t', builtin.git_files, {})
		else
			vim.keymap.set('n', '<leader>t', builtin.find_files, {})
		end
	end
}
