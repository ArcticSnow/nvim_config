vim.g.mapleader = " "
vim.keymap.set("n", "<leader>cd", vim.cmd.Ex)


-- move through buffers using n, p, and x to close buffer
vim.keymap.set("n", "<leader>n",":bn<cr>")   -- move to next buffer
vim.keymap.set("n", "<leader>p",":bp<cr>")   -- move to previous buffer
vim.keymap.set("n", "<leader>x",":bd<cr>")   -- close buffer



