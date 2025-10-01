-- ===================================================
--  Title: Plugin to get multiple cursor like in Sublime 
--  URL: https://github.com/brenton-leighton/multiple-cursors.nvim
-- 
-- ===================================================

return {
    {
    "brenton-leighton/multiple-cursors.nvim",
    version = "*",  -- Use the latest tagged version
    opts = {},  -- This causes the plugin setup function to be called
    keys = {
	{"<S-j>", "<Cmd>MultipleCursorsAddDown<CR>", mode = {"n", "x"}, desc = "Add cursor and move down"},
	{"<S-k>", "<Cmd>MultipleCursorsAddUp<CR>", mode = {"n", "x"}, desc = "Add cursor and move up"},

	{"<S-Up>", "<Cmd>MultipleCursorsAddUp<CR>", mode = {"n", "i", "x"}, desc = "Add cursor and move up"},
	{"<S-Down>", "<Cmd>MultipleCursorsAddDown<CR>", mode = {"n", "i", "x"}, desc = "Add cursor and move down"},

	{"<S-LeftMouse>", "<Cmd>MultipleCursorsMouseAddDelete<CR>", mode = {"n", "i"}, desc = "Add or remove cursor"},

	{"<S-m", "<Cmd>MultipleCursorsAddVisualArea<CR>", mode = {"x"}, desc = "Add cursors to the lines of the visual area"},

	-- {"<Leader>a", "<Cmd>MultipleCursorsAddMatches<CR>", mode = {"n", "x"}, desc = "Add cursors to cword"},
	-- {"<Leader>A", "<Cmd>MultipleCursorsAddMatchesV<CR>", mode = {"n", "x"}, desc = "Add cursors to cword in previous area"},

	{"<S-d", "<Cmd>MultipleCursorsAddJumpNextMatch<CR>", mode = {"n", "x"}, desc = "Add cursor and jump to next cword"},
	{"<S-D", "<Cmd>MultipleCursorsJumpNextMatch<CR>", mode = {"n", "x"}, desc = "Jump to next cword"},

	{"<S-l", "<Cmd>MultipleCursorsLock<CR>", mode = {"n", "x"}, desc = "Lock virtual cursors"},
    },
    }
}
