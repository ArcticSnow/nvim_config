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


-- function to delete files from within neovim. Files are sent to the computer trashbin
vim.api.nvim_create_user_command('DeleteFile',  function()
  local filename = vim.api.nvim_buf_get_name(0)
  if filename ~= '' then
    os.execute('gio trash "' .. filename .. '"')
  end
  require('custom.plugins.utils').destroy_buffer()
end, {})
vim.keymap.set('n', '<leader>rm', ':DeleteFile', { desc = 'Delete current file (to trash)'})


-- autocommand when entering terminal command to go automatically in insert mode
vim.api.nvim_create_autocmd({ 'WinEnter', 'BufWinEnter' }, {
  pattern = { 'term://*' },
  command = 'startinsert',
})
