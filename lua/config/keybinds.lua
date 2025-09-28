vim.g.mapleader = " "
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
