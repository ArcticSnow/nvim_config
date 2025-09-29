local function enable_transparency()
    vim.api.nvim_set_hl(0, "Normal", {bg="none"})
end

return{
    -- lua/plugins/rose-pine.lua
-- {
-- 	"rose-pine/neovim",
-- 	name = "rose-pine",
-- 	config = function()
-- 		vim.cmd("colorscheme rose-pine-dawn")
-- 	end
-- },
    {
	"folke/tokyonight.nvim",
	config = function()
	    vim.cmd.colorscheme "tokyonight"
--	    enable_transparency()
	end
    },
    {
	"nvim-lualine/lualine.nvim",
	dependencies = {
	    "nvim-tree/nvim-web-devicons",
	},
	opts = {
	    --theme = 'tokyonight',
	    theme = 'rose-pine',
	}
    }

}



