--------------------------------------------------------
--- Load keymaps 

require("config.options")
require("config.keybinds")
require("config.lazy")






-- ###########################################
--           My personal Lua functions 
-- ##########################################


local repl = require('my_plugins.repl')

-- Map a key in visual mode (`v` and `x`) to send the selection.
--vim.keymap.set({'v', 'x'}, '<leader>se', function()
  -- Get the start (`<`) and end (`>`) line numbers of the visual selection.
  -- The `[1]` is used to extract the line number from the returned table.
--  local start_line = vim.api.nvim_buf_get_mark(0, '<')[1]
--  local end_line = vim.api.nvim_buf_get_mark(0, '>')[1]

  -- Call the function with the selected line numbers.
--  repl.send_visual_selection_to_terminal(start_line, end_line)
--end, { desc = 'Send selected lines to terminal' })



--vim.keymap.set('n', '<leader>sl', function()
--  repl.send_current_line_to_terminal()
--end, { desc = 'Send current line to terminal' })

