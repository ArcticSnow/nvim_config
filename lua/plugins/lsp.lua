return {
    {
	'mason-org/mason.nvim',
	opts = {},
    },
    {
	"mason-org/mason-lspconfig.nvim",
	opts = {
	    ensure_installed = {
		"clangd",
		"fortls",
		"html",
		"julials",
		"lua_ls",
		"markdown_oxide",
		"pyright",
		"rust_analyzer",
		"ts_ls",
		"yamlls"

	    },
	},
    },
    {
	"neovim/nvim-lspconfig",
	config = function()
	    vim.lsp.enable("clangd")
	    vim.lsp.enable("fortls")
	    vim.lsp.enable("html")
	    vim.lsp.enable("julials")
	    vim.lsp.enable("lua_ls")
	    vim.lsp.enable("markdown_oxide")
	    vim.lsp.enable("pyright")
	    vim.lsp.enable("rust_analyser")
	    vim.lsp.enable("ts_ls")
	    vim.lsp.enable("yamlls")
	end
    },
}
