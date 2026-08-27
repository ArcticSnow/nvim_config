-- =====================================================================
-- [ ]- title: nvm keymaps
--
-- =====================================================================
vim.g.mapleader = " "
vim.g.globalleader = " "

vim.keymap.set("n", "<leader>cd", vim.cmd.ex)

-- add tab to line in visual mode
--vim.keymap.set('v', '<Tab>', '>', { noremap = true, silent = true })


-- function to force keymaps (https://readmedium.com/must-have-neovim-keymaps-51c283394070)
function Map(mode, lhs, rhs, opts)
    local options = { noremap = true, silent = true }
    if opts then
        options = vim.tbl_extend("force", options, opts)
    end
    vim.keymap.set(mode, lhs, rhs, options)
end


-- ##############      BibTeX Citation Module             ##########################
-- Search and insert bibtex citation
vim.keymap.set("n", "<leader>bb", function() require("custom.plugins.bibtex_finder").search_and_insert() end, {
  noremap = true,
  silent = true,
  desc = "Insert BibTeX reference",
})


-- Keymap to select bib file
vim.keymap.set('n', '<leader>bz', function()
  require('custom.plugins.bibtex_finder').select_bib_file()
end, { desc = "Select BibTeX file" })


-- ##############  Other Custom Nodules: docstrings, templates, ToC      ##########################
-- Generate and insert Python docstring
local docstring = require("custom.plugins.docstring")
vim.keymap.set("n", "<leader>dc", function() docstring.generate() end, {
  noremap = true,
  silent = true,
  desc = "Generate Python docstring",
})

-- Search and insert file templates
local templates = require("custom.plugins.templater")

vim.keymap.set("n", "<leader>tm", function() templates.pick(templates.insert) end, {
  noremap = true,
  silent = true,
  desc = "Insert template",
})

-- Display and navigate Table of Contents using Telescope
vim.keymap.set("n", "<leader>ft", function()
	require('custom.plugins.toc').open_toc()
end, { desc = "Table of Contents" })

-- Destroy current buffer without closing window
vim.keymap.set({ 'n' }, '<leader>bd', function()
  require('custom.plugins.utils').destroy_buffer()
end, { desc = 'Destroy current buffer but do not close its window' })

-- Indentation of mulitple line simplified
vim.keymap.set("v", "<", "<gv", { noremap = true })
vim.keymap.set("v", ">", ">gv", { noremap = true })

-- Keymap to simplify interaction with quickfix
vim.keymap.set("n", "]]", "<cmd>cnext<CR>", { silent = true })
vim.keymap.set("n", "[[", "<cmd>cprev<CR>", { silent = true })
vim.keymap.set("n", "<c-[>", "<cmd>cclose<CR>", { silent = true })  -- to be checked

-- move through buffers using n, p, and x to close buffer
vim.keymap.set("n", "<tab>","<cmd>bnext<cr>", {noremap=true, desc = "Move to next buffer"})   -- move to next buffer
vim.keymap.set("n", "<S-tab>","<cmd>bprevious<cr>", {noremap=true, desc = "Move to previous buffer"})   -- move to previous buffer
-- vim.keymap.set("n", "<q-tab>","<cmd>bd<cr>", {desc = "Close current buffer"})   -- move to previous buffer


-- ##############      OIL             ##########################
vim.keymap.set('n', '-', '<CMD>Oil<CR>', { desc = 'Open parent directory' })
vim.keymap.set('n', '+', '<CMD>Oil --float<CR>', { desc = 'Open parent directory - in floating window' })

-- ##############      Kitty REPL             ##########################
vim.keymap.set('n', '<leader>rs', require('custom.plugins.kitty_repl').select_repl, {desc = 'Select REPL'})
vim.keymap.set('n', '<leader>ri', require('custom.plugins.kitty_repl').repl_status, {desc = 'REPL status'})
vim.keymap.set('n', '<leader>rt', function()
  require('custom.plugins.kitty_repl').new_repl()
end, { desc = 'Open Kitty Terminal REPL' })

vim.keymap.set('n', '<leader>rp', function()
  require('custom.plugins.kitty_repl').new_python_repl()
end, { desc = 'Open Kitty Python REPL' })



vim.keymap.set({'n', 'i'}, '<A-c>', function()
  require('custom.plugins.kitty_repl').send_current_codeblock()
end, { desc = 'Send current codeblock to REPL' })

vim.keymap.set('v', '<A-s>', function()
  require('custom.plugins.kitty_repl').send_visual()
end, { desc = 'Send visual selection to REPL' })

vim.keymap.set({ 'n', 'i' }, '<A-s>', function()
  require('custom.plugins.kitty_repl').send_line()
end, { desc = 'Send current line to REPL' })

vim.keymap.set({ 'n' }, 's', function()
  vim.go.operatorfunc = "v:lua.require'custom.plugins.kitty_repl'.send_motion"
  return 'g@'
end, { expr = true, desc = 'Send lines to REPL using a motion' })

vim.keymap.set('n', '<A-x>', 'six', {desc = "Send current code block to REPL"})


-- -- ##############      Simple REPL             ##########################
-- vim.api.nvim_create_user_command('Repl', function(opts)
--   require('custom.plugins.term').toggle_repl()
-- end, { range = false })
--
-- vim.keymap.set('n', '<leader>tv', '<CMD>vsplit +Repl<CR>', { desc = 'Open REPL in vertical split' })
-- vim.keymap.set('n', '<leader>th', '<CMD>split +Repl<CR>', { desc = 'Open REPL in horizontal split' })
-- vim.keymap.set('n', '<leader>tr', '<CMD>Repl<CR>', { desc = 'Open REPL in current window' })
--
--
-- vim.keymap.set('v', 's', function()
--   require('custom.plugins.term').send_visual()
-- end, { desc = 'Send visual selection to REPL' })
--
-- vim.keymap.set({ 'n', 'i' }, '<A-s>', function()
--   require('custom.plugins.term').send_line()
-- end, { desc = 'Send current line to REPL' })
--
-- vim.keymap.set({ 'n' }, 's', function()
--   vim.go.operatorfunc = "v:lua.require'custom.plugins.term'.send_motion"
--   return 'g@'
-- end, { expr = true, desc = 'Send lines to REPL using a motion' })
--
-- vim.keymap.set('n', '<leader>6', 'six', {desc = "Send current code block to REPL"})

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
vim.keymap.set("n", "<c-right>", "<cmd>vertical resize -2<cr>", { desc = "decrease window width" })
vim.keymap.set("n", "<c-left>", "<cmd>vertical resize +2<cr>", { desc = "increase window width" })


-- =======================================================
-- Python venv selector

vim.keymap.set("n", "<leader>pv", "<cmd>VenvSelect<cr>", { expr = true, desc = 'Select Python venv' })


-- =======================================================
vim.keymap.set("n", "fi", "zi", {desc = "Toggle folding"})

vim.keymap.set("n", "fa", "za", {desc = "Toggle fold under cursor"})
vim.keymap.set("n", "fh", "[zjk",{desc = "go to start of fold"})
vim.keymap.set("n", "fj", "zjkj",{desc = "go to next fold"})
vim.keymap.set("n", "fk", "zk[z",{desc = "go to prev fold"})
vim.keymap.set("n", "fl", "]zkj",{desc = "go to end of fold"})

-- ===========================================================

-- Personalized adaptation of classical Vim motion
vim.keymap.set('n', '{', 'k{j_', {desc="go to first line of previous paragraph"})  -- go to first line of previous paragraph
vim.keymap.set('n', '}', '}j_', {desc="go to first line of next paragraph"})  -- got to first line of next paragraph

vim.keymap.set('v', 'p', 'ip', {desc="select inside paragraph"})  -- shorten vip to vp to select paragraph. can be used vppp to select subsequent paragraph
