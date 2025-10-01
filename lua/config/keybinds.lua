-- =====================================================================
-- Title: Nvm keymaps 
--
-- =====================================================================


vim.g.mapleader = " "
vim.g.globalleader = " "

vim.keymap.set("n", "<leader>cd", vim.cmd.Ex)


-- move through buffers using n, p, and x to close buffer
vim.keymap.set("n", "<leader>n",":bn<cr>")   -- move to next buffer
vim.keymap.set("n", "<leader>p",":bp<cr>")   -- move to previous buffer
vim.keymap.set("n", "<leader>x",":bd<cr>")   -- close buffer

-- Keymaps for ToggleTerm to send lines of codes to terminal
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
-- Terminal
-- Better terminal navigation

local n_opts = {silent = true, noremap = true}
local t_opts = {silent = true}

-- Mode normal
-- Meilleure navigation dans les fenêtres
vim.keymap.set('n', '<C-Left>', '<C-w>h', n_opts)
vim.keymap.set('n', '<C-Down>', '<C-w>j', n_opts)
vim.keymap.set('n', '<C-Up>', '<C-w>k', n_opts)
vim.keymap.set('n', '<C-Right>', '<C-w>l', n_opts)

-- Mode terminal
vim.keymap.set('t', '<esc>', '<C-\\><C-N>', t_opts)
vim.keymap.set('t', '<C-Left>', '<C-\\><C-N><C-w>h', t_opts)
vim.keymap.set('t', '<C-Down>', '<C-\\><C-N><C-w>j', t_opts)
vim.keymap.set('t', '<C-Up>', '<C-\\><C-N><C-w>k', t_opts)
vim.keymap.set('t', '<C-Right>', '<C-\\><C-N><C-w>l', t_opts)

-- ==================================================
-- Better window navigation
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to bottom window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to top window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- Splitting & Resizing
vim.keymap.set("n", "<leader>sv", "<Cmd>vsplit<CR>", { desc = "Split window vertically" })
vim.keymap.set("n", "<leader>sh", "<Cmd>split<CR>", { desc = "Split window horizontally" })
vim.keymap.set("n", "<C-Up>", "<Cmd>resize +2<CR>", { desc = "Increase window height" })
vim.keymap.set("n", "<C-Down>", "<Cmd>resize -2<CR>", { desc = "Decrease window height" })
vim.keymap.set("n", "<C-Left>", "<Cmd>vertical resize -2<CR>", { desc = "Decrease window width" })
vim.keymap.set("n", "<C-Right>", "<Cmd>vertical resize +2<CR>", { desc = "Increase window width" })
