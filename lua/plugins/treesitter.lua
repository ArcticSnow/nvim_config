return {
    'nvim-treesitter/nvim-treesitter',
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    lazy = false,
    config = function()
	require("nvim-treesitter.configs").setup({
	    highlight = {
		enable = true,
		additional_vim_regex_highlighting = false,
	    },
	    indent = {enable = true},
	    autotage = {enable = true},
	    ensure_installed = {"lua",
		"python",
		"markdown",
		"yaml",
		"julia",
		"ini",
		"fortran",
		"bibtex"
		,"markdown_inline"},
	    auto_install = true,
	    incremental_selection = {
		enable = true,
		keymaps = {
		    init_selection = "<CR>",
		    node_incremental = "<CR>",
		    scope_incremental = "<TAB>",
		    node_decremental = "<S-TAB>",
		},
	    },
	})
    end
}
