-- =====================================================================
-- title: nvm keymaps 
--
-- =====================================================================
vim.g.mapleader = " "
vim.g.globalleader = " "

vim.keymap.set("n", "<leader>cd", vim.cmd.ex)



-- function to force keymaps (https://readmedium.com/must-have-neovim-keymaps-51c283394070)
function Map(mode, lhs, rhs, opts)
    local options = { noremap = true, silent = true }
    if opts then
        options = vim.tbl_extend("force", options, opts)
    end
    vim.keymap.set(mode, lhs, rhs, options)
end

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Shortcut to move from one codeblock cell to another one in quarto files
local function jump_forward_to_content()
  -- 1. Search for the next code block start (``` followed by a non-space character, like '```python')
  -- '^\\s*```\\S' matches the opening fence, e.g., '```python' or '```r'
  vim.fn.search('^\\s*```\\S', 'W')
  -- 2. Search again, starting from the current line, for the first line *that is not empty*.
  vim.fn.search('^\\S', 'W')
end

local function jump_backward_to_content()
  -- 1. Search backward for the closing fence (```$)
  vim.fn.search('^\\s*```$', 'bW')
  -- 2. Move up two lines (2k) to land in the content of the PREVIOUS block.
  vim.cmd('normal! 2k')
end

-- Map <Leader>n to jump forward
vim.keymap.set('n', '<Leader>cn', jump_forward_to_content, { desc = 'Jump to next code block (Standard Markdown)' })

-- Map <Leader>N to jump backward
vim.keymap.set('n', '<Leader>cb', jump_backward_to_content, { desc = 'Jump to previous code block (Standard Markdown)' })
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++



-- Indentation of mulitple line simplified
Map("v", ">", "<gv")
Map("v", "<", ">gv")



-- Keymap to simplify interaction with quickfix
vim.keymap.set("n", "]]", "<cmd>cnext<CR>", { silent = true })
vim.keymap.set("n", "[[", "<cmd>cprev<CR>", { silent = true })
vim.keymap.set("n", "<c-[>", "<cmd>cclose<CR>", { silent = true })  -- to be checked

-- move through buffers using n, p, and x to close buffer
vim.keymap.set("n", "<tab>","<cmd>bnext<cr>", {desc = "Move to next buffer"})   -- move to next buffer
vim.keymap.set("n", "<S-tab>","<cmd>bprevious<cr>", {desc = "Move to previous buffer"})   -- move to previous buffer
-- vim.keymap.set("n", "<q-tab>","<cmd>bd<cr>", {desc = "Close current buffer"})   -- move to previous buffer

-- ##############      Simple REPL             ##########################
vim.api.nvim_create_user_command('Repl', function(opts)
  require('custom.plugins.term').toggle_repl()
end, { range = false })

vim.keymap.set('n', '<leader>tv', '<CMD>vsplit +Repl<CR>', { desc = 'Open REPL in vertical split' })
vim.keymap.set('n', '<leader>th', '<CMD>split +Repl<CR>', { desc = 'Open REPL in horizontal split' })
vim.keymap.set('n', '<leader>tr', '<CMD>Repl<CR>', { desc = 'Open REPL in current window' })


vim.keymap.set('v', 's', function()
  require('custom.plugins.term').send_visual()
end, { desc = 'Send visual selection to REPL' })

vim.keymap.set({ 'n', 'i' }, '<A-s>', function()
  require('custom.plugins.term').send_line()
end, { desc = 'Send current line to REPL' })

vim.keymap.set({ 'n' }, 's', function()
  vim.go.operatorfunc = "v:lua.require'custom.plugins.term'.send_motion"
  return 'g@'
end, { expr = true, desc = 'Send lines to REPL using a motion' })

vim.keymap.set('n', '<leader>6', 'six', {desc = "Send current code block to REPL"})

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
