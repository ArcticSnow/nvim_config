-- =====================================================================
-- title: nvm keymaps 
--
-- =====================================================================

-- function to force keymaps (https://readmedium.com/must-have-neovim-keymaps-51c283394070)
function Map(mode, lhs, rhs, opts)
    local options = { noremap = true, silent = true }
    if opts then
        options = vim.tbl_extend("force", options, opts)
    end
    vim.keymap.set(mode, lhs, rhs, options)
end

-- Indentation of mulitple line simplified
Map("v", ">", "<gv")
Map("v", "<", ">gv")

vim.g.mapleader = " "
vim.g.globalleader = " "

vim.keymap.set("n", "<leader>cd", vim.cmd.ex)


-- move through buffers using n, p, and x to close buffer
vim.keymap.set("n", "<leader>n",":bn<cr>")   -- move to next buffer
vim.keymap.set("n", "<leader>p",":bp<cr>")   -- move to previous buffer
vim.keymap.set("n", "<leader>x",":bd<cr>")   -- close buffer

-- keymaps for toggleterm to send lines of codes to terminal
local trim_spaces = true
vim.keymap.set("v", "<space>ss", function()
    require("toggleterm").send_lines_to_terminal("single_line", trim_spaces, { args = vim.v.count })
end)
vim.keymap.set("v", "<space>sl", function()
    require("toggleterm").send_lines_to_terminal("visual_lines", trim_spaces, { args = vim.v.count })
end)
vim.keymap.set("v", "<space>sv", function()
    require("toggleterm").send_lines_to_terminal("visual_selection", trim_spaces, { args = vim.v.count })
end)

-- =========================================
-- terminal
-- better terminal navigation

local n_opts = {silent = true, noremap = true}
local t_opts = {silent = true}

-- mode normal
-- meilleure navigation dans les fenêtres
vim.keymap.set('n', '<c-left>', '<c-w>h', n_opts)
vim.keymap.set('n', '<c-down>', '<c-w>j', n_opts)
vim.keymap.set('n', '<c-up>', '<c-w>k', n_opts)
vim.keymap.set('n', '<c-right>', '<c-w>l', n_opts)

-- mode terminal
vim.keymap.set('t', '<esc>', '<c-\\><c-n>', t_opts)
vim.keymap.set('t', '<c-left>', '<c-\\><c-n><c-w>h', t_opts)
vim.keymap.set('t', '<c-down>', '<c-\\><c-n><c-w>j', t_opts)
vim.keymap.set('t', '<c-up>', '<c-\\><c-n><c-w>k', t_opts)
vim.keymap.set('t', '<c-right>', '<c-\\><c-n><c-w>l', t_opts)

-- ==================================================
-- better window navigation
vim.keymap.set("n", "<c-h>", "<c-w>h", { desc = "move to left window" })
vim.keymap.set("n", "<c-j>", "<c-w>j", { desc = "move to bottom window" })
vim.keymap.set("n", "<c-k>", "<c-w>k", { desc = "move to top window" })
vim.keymap.set("n", "<c-l>", "<c-w>l", { desc = "move to right window" })

-- splitting & resizing
vim.keymap.set("n", "<leader>sv", "<cmd>vsplit<cr>", { desc = "split window vertically" })
vim.keymap.set("n", "<leader>sh", "<cmd>split<cr>", { desc = "split window horizontally" })
vim.keymap.set("n", "<c-up>", "<cmd>resize +2<cr>", { desc = "increase window height" })
vim.keymap.set("n", "<c-down>", "<cmd>resize -2<cr>", { desc = "decrease window height" })
vim.keymap.set("n", "<c-left>", "<cmd>vertical resize -2<cr>", { desc = "decrease window width" })
vim.keymap.set("n", "<c-right>", "<cmd>vertical resize +2<cr>", { desc = "increase window width" })
