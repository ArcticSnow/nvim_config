local M = {}

-- This function finds the first terminal buffer and returns its job ID (channel ID)
-- If no terminal is open, it opens one.
local function find_or_open_terminal()
  -- Loop through all open buffers
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[bufnr].buftype == 'terminal' then
      -- Found an existing terminal buffer
      -- The job ID is stored in the buffer's variable `b:terminal_job_id`
      local job_id = vim.b[bufnr].terminal_job_id
      if job_id then
        return job_id
      end
    end
  end

  -- If no terminal buffer is found, open a new one
  local term_buf = vim.api.nvim_buf_open_term(nil, {})
  vim.api.nvim_set_option_value('buflisted', false, { scope = 'local', buf = term_buf })
  vim.cmd('enew | set buftype=terminal | startinsert!')
  return vim.api.nvim_get_current_chan()
end

-- Function to send selected lines to the terminal
-- The `lines_start` and `lines_end` arguments are automatically provided
-- by the `vmap` command's range.
function M.send_visual_selection_to_terminal(lines_start, lines_end)
  -- Get the current buffer number
  local current_buf = vim.api.nvim_get_current_buf()

  -- Get the selected lines
  -- Note: nvim_buf_get_lines uses 0-based indexing and excludes the end line
  local selected_lines = vim.api.nvim_buf_get_lines(
    current_buf,
    lines_start - 1, -- start is 1-based, Lua is 0-based
    lines_end,
    false
  )

  -- Get the terminal's channel ID
  local terminal_chan = find_or_open_terminal()

  if terminal_chan then
    -- Join the lines with a newline character for multi-line execution
    local code_to_send = table.concat(selected_lines, '\n') .. '\n'

    -- Send the code to the terminal
    vim.api.nvim_chan_send(terminal_chan, code_to_send)
  else
    vim.notify('Could not find or open a terminal.', vim.log.levels.WARN)
  end
end


function M.send_current_line_to_terminal()
  -- Get the current line number (0-indexed)
  local current_line_num = vim.api.nvim_get_current_line_number() - 1
  -- Get the current line's text
  local current_line_text = vim.api.nvim_buf_get_lines(
    0, -- 0 refers to the current buffer
    current_line_num,
    current_line_num + 1,
    false
  )

  local terminal_chan = find_or_open_terminal()
  if terminal_chan then
    -- Add a newline to ensure the command is executed
    local code_to_send = current_line_text[1] .. '\n'
    vim.api.nvim_chan_send(terminal_chan, code_to_send)
  else
    vim.notify('Could not find or open a terminal.', vim.log.levels.WARN)
  end
end


return M
