return {
    {
	'mason-org/mason.nvim',
	opts = {},
    },
    {
	"mason-org/mason-lspconfig.nvim",
	opts = {
	    ensure_installed = {
		"lua_ls",
		"pyright",
		"ts_ls",
		"rust_analyzer",
		"clangd",
		"julials",
		"html",
		"markdown_oxide",
		"fortls",
		"yamlls"

	    },
	},
    },
    {
	"neovim/nvim-lspconfig",
	config = function()
	    vim.lsp.enable("lua_ls")
	    vim.lsp.enable("pyright")
	    vim.lsp.enable("ts_ls")
	    vim.lsp.enable("rust_analyser")
	    vim.lsp.enable("clangd")
	    vim.lsp.enable("julials")
	    vim.lsp.enable("html")
	    vim.lsp.enable("markdown_oxide")
	    vim.lsp.enable("fortls")
	    vim.lsp.enable("yamlls")
	end
    },
}
