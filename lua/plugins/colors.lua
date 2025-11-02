-- local function enable_transparency()
--     vim.api.nvim_set_hl(0, "Normal", {bg="none"})
-- end

return{
	    {
		"rose-pine/neovim",
		name = "rose-pine",
		config = function()
		    vim.cmd("colorscheme rose-pine-dawn")
		end
	    },
	{
	    "neanias/everforest-nvim",
	    version = false,
	    lazy = false,
	    priority = 100, -- make sure to load this before all the other start plugins
	    -- Optional; default configuration will be used if setup isn't called.
	    config = function()
		require("everforest").setup({
		    -- Your config here
		})
	    end,
	},
	{
	    "folke/tokyonight.nvim",
	    config = function()
		vim.cmd.colorscheme "tokyonight"
		--	    enable_transparency()
	    end
	},
	{"nvim-lualine/lualine.nvim",
	    config = function()
	    local CurrentColorScheme = vim.g.colors_name or 'default'
		require("lualine").setup({
		    options = {
			--theme = CurrentColorScheme,
			icons_enabled = true,
			section_separators = { left = "", right = "" },
			component_separators = "|",
		    },
		})
	    end,
	    dependencies = { "nvim-tree/nvim-web-devicons" },
	}
}


