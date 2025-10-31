
-- ################### Quarto related commands  #############################
-- set of functions and utilities related to quarto files (qmd)


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


local function jump_forward_to_content()
  -- Shortcut to move from one codeblock cell to another one in quarto files
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


vim.keymap.set('n', '<Leader>cn', jump_forward_to_content, { desc = 'Jump to next code block (Standard Markdown)' })
vim.keymap.set('n', '<Leader>cb', jump_backward_to_content, { desc = 'Jump to previous code block (Standard Markdown)' })
vim.keymap.set('n', '<leader>cc', insert_python_code_block, { desc = 'Insert Python code block' })
vim.keymap.set('n', '<leader>cs', split_python_code_block, { desc = 'Split Python code block' })

-- set of functions and utilities related to quarto files )qmd


