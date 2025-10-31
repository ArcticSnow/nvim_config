local M = {}

-- Store the empty buffer number
local empty_bufnr = nil

--- Destroy a buffer and show an empty buffer in all windows displaying it.
-- @param bufnr (number) Buffer number to destroy. If nil, uses current buffer.
function M.destroy_buffer(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local windows = vim.api.nvim_list_wins()

  -- Create the empty buffer once and reuse it
  if not (empty_bufnr and vim.api.nvim_buf_is_valid(empty_bufnr)) then
    empty_bufnr = vim.api.nvim_create_buf(true, false)
    vim.api.nvim_buf_set_option(empty_bufnr, 'buflisted', false)
  end

  -- For each window, if it shows the buffer, switch to the empty buffer
  for _, win in ipairs(windows) do
    if vim.api.nvim_win_get_buf(win) == bufnr then
      vim.api.nvim_win_set_buf(win, empty_bufnr)
    end
  end

  -- Delete the buffer
  vim.api.nvim_buf_delete(bufnr, { force = true })
end

return M
