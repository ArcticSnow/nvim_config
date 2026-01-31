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
vim.api.nvim_create_autocmd({ 'WinEnter', 'BufWinEnter', 'TermOpen' }, {
  pattern = { 'term://*' },
  command = 'startinsert',
})


-- 1. Create the user command: :ImageRender
vim.api.nvim_create_user_command(
    'ImageRender',                                  -- The name of the new command
    function()
        -- Safely require the 'image' module and call its render method
        local ok, image = pcall(require, "image")
        if ok and image and image.render then
            image.render()
        else
            -- Display an error if the module or function is missing
            vim.notify("Error: 'image' module not found or missing render() function.", vim.log.levels.ERROR)
        end
    end,
    {
        -- Options for the command
        desc = 'Render images in the current buffer using image.nvim',
        nargs = 0, -- Takes zero arguments
    }
)
