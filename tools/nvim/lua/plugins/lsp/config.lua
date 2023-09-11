local lspconfig = require("lspconfig")
local mason_lspconfig = require("mason-lspconfig")
local mason_null_ls = require("mason-null-ls")
local mason = require("mason")

local format_group = vim.api.nvim_create_augroup("LspFormatting", { clear = true })
local null_ls = require("null-ls")
local cmp_nvim_lsp = require("cmp_nvim_lsp")

local M = {}

function M.setup()
	mason.setup()

	null_ls.setup({
		on_attach = function(client, bufnr)
			if client.supports_method("textDocument/formatting") then
				vim.api.nvim_clear_autocmds({ group = format_group, buffer = bufnr })
				vim.api.nvim_create_autocmd("BufWritePre", {
					group = format_group,
					buffer = bufnr,
					callback = function()
						vim.lsp.buf.format({
							---@diagnostic disable-next-line: redefined-local
							filter = function(client)
								return client.name == "null-ls"
							end,
							bufnr = bufnr,
						})
					end,
				})
			end
		end,
	})

	mason_null_ls.setup({
		automatic_installation = true,
		ensure_installed = { "stylua", "prettier" },
		handlers = {
			function(source_name, methods)
				require("mason-null-ls.automatic_setup")(source_name, methods)
			end,
		},
	})

	mason_lspconfig.setup({
		ensure_installed = { "tsserver", "lua_ls", "denols", "vimls", "astro", "svelte", "tailwindcss", "prismals" },
		automatic_installation = true,
		ui = { check_outdated_servers_on_open = true },
	})

	mason_lspconfig.setup_handlers({
		function(server_name)
			lspconfig[server_name].setup({})
		end,

		tsserver = function()
			lspconfig.tsserver.setup({
				handlers = {
					["textDocument/definition"] = function(err, result, ctx, ...)
						if #result > 1 then
							result = { result[1] }
						end
						vim.lsp.handlers["textDocument/definition"](err, result, ctx, ...)
					end,
				},
				root_dir = require("lspconfig/util").root_pattern("tsconfig.json"),
			})
		end,

		denols = function()
			lspconfig.denols.setup({
				handlers = {
					["textDocument/definition"] = function(err, result, ctx, ...)
						vim.notify("Using new definition handler")
						if #result > 1 then
							result = { result[1] }
						end
						vim.lsp.handlers["textDocument/definition"](err, result, ctx, ...)
					end,
				},
				root_dir = require("lspconfig/util").root_pattern("deno.json", "deno.jsonc"),
				init_options = { lint = true },
			})
		end,

		lua_ls = function()
			lspconfig.lua_ls.setup({
				settings = {
					Lua = {
						completion = { callSnippet = "Replace" },
						runtime = {
							-- LuaJIT in the case of Neovim
							version = "LuaJIT",
							path = vim.split(package.path, ";"),
						},
						diagnostics = {
							-- Get the language server to recognize the `vim` global
							globals = { "vim" },
						},
						workspace = {
							library = vim.api.nvim_get_runtime_file("", true),
							checkThirdParty = false,
						},
					},
				},
			})
		end,

		vimls = function()
			lspconfig.vimls.setup({
				init_options = { isNeovim = true },
			})
		end,

		diagnosticls = function()
			lspconfig.diagnosticls.setup({
				settings = {
					filetypes = { "sh" },
					init_options = {
						linters = {
							shellcheck = {
								sourceName = "shellcheck",
								command = "shellcheck",
								debounce = 100,
								args = { "--format=gcc", "-" },
								offsetLine = 0,
								offsetColumn = 0,
								formatLines = 1,
								formatPattern = {
									"^[^:]+:(\\d+):(\\d+):\\s+([^:]+):\\s+(.*)$",
									{ line = 1, column = 2, message = 4, security = 3 },
								},
								securities = { error = "error", warning = "warning", note = "info" },
							},
						},
						filetypes = { sh = "shellcheck" },
					},
				},
			})
		end,

		jsonls = function()
			lspconfig.jsonls.setup({
				filetypes = { "json", "jsonc" },
			})
		end,

		prismals = lspconfig.prismals.setup({}),
	})
end

return M
