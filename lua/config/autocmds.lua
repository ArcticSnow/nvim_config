-- ================================================================================================
-- TITLE : auto-commands
-- ABOUT : automatically run code on defined events (e.g. save, yank)
-- ================================================================================================

-- Restore last cursor position when reopening a file
local last_cursor_group = vim.api.nvim_create_augroup("LastCursorGroup", {})
vim.api.nvim_create_autocmd("BufReadPost", {
    group = last_cursor_group,
    callback = function()
	local mark = vim.api.nvim_buf_get_mark(0, '"')
	local lcount = vim.api.nvim_buf_line_count(0)
	if mark[1] > 0 and mark[1] <= lcount then
	    pcall(vim.api.nvim_win_set_cursor, 0, mark)
	end
    end,
})

-- Highlight the yanked text for 200ms
local highlight_yank_group = vim.api.nvim_create_augroup("HighlightYank", {})
vim.api.nvim_create_autocmd("TextYankPost", {
    group = highlight_yank_group,
    pattern = "*",
    callback = function()
	vim.hl.on_yank({
	    higroup = "IncSearch",
	    timeout = 200,
	})
    end,
})




-- ################### Quarto commands  #############################

vim.api.nvim_create_user_command('GetCodeblocks', function(opts)
  -- package.loaded['custom.plugins.term'] = nil
  local term = require 'custom.plugins.term'
  local start = tonumber(opts.fargs[1])
  local stop = tonumber(opts.fargs[2])
  local num_blocks = tonumber(opts.fargs[3])
  -- term.get_codeblocks(start, stop, num_blocks)
  term.send_codeblocks_before_cursor()
end, { nargs = '*' })


local function insert_python_code_block()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local lines = { '```{python}', '', '```' }
  vim.api.nvim_buf_set_lines(0, row, row, false, lines)
  vim.api.nvim_win_set_cursor(0, { row + 2, 0 })
  vim.cmd 'startinsert'
end

local function split_python_code_block()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local lines = { '```', '', '```{python}' }
  vim.api.nvim_buf_set_lines(0, row, row, false, lines)
end

vim.keymap.set('n', '<leader>cc', insert_python_code_block, { desc = 'Insert Python code block' })
vim.keymap.set('n', '<leader>cs', split_python_code_block, { desc = 'Split Python code block' })
