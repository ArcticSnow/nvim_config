-- File: /home/simonfi/.config/nvim/lua/config/window_focus.lua

-- Require the new utility module
local color_utils = require('custom.plugins.color_utils')

-- Define global variables for the calculated colors
local ACTIVE_COLOR = nil
local INACTIVE_COLOR = nil

-- Define the highlight groups to be applied (aggressive winhighlight)
local ACTIVE_WHL = 'Normal:ActiveWindow,LineNr:ActiveWindow,EndOfBuffer:ActiveWindow'
local INACTIVE_WHL = 'Normal:InactiveWindow,LineNr:InactiveWindow,EndOfBuffer:InactiveWindow'

-- Function to calculate colors and define the highlight groups
local function setup_dynamic_colors()
  -- 1. Get the current colorscheme's background (Normal highlight group)
  local hl = vim.api.nvim_get_hl_by_name('Normal', true)
  
  -- The guibg attribute is usually a 24-bit color code (e.g., 0x1f2335)
  local current_bg = hl.background
  
  -- Convert the number to a hex string: "#1f2335"
  local hex_bg = string.format("#%06x", current_bg)
  
  -- 2. Calculate the new, lighter background color (5% lighter)
  INACTIVE_COLOR = color_utils.lighten(hex_bg, 0.1) 
  ACTIVE_COLOR = hex_bg -- Inactive is just the theme's default background

  -- 3. Redefine the highlight groups with the new dynamic colors
  -- Note: We omit ctermbg as it's harder to calculate dynamically
  vim.cmd("highlight ActiveWindow guibg=" .. ACTIVE_COLOR)
  vim.cmd("highlight InactiveWindow guibg=" .. INACTIVE_COLOR)
end

-- The function to apply the highlights remains the same
local function highlight_active_window()
  -- Ensure colors are set before running the loop
  if not ACTIVE_COLOR then
    setup_dynamic_colors()
  end

  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local bufnr = vim.api.nvim_win_get_buf(win)
    
    if win == vim.api.nvim_get_current_win() then
      vim.api.nvim_buf_set_option(bufnr, 'winhighlight', ACTIVE_WHL)
    else
      vim.api.nvim_buf_set_option(bufnr, 'winhighlight', INACTIVE_WHL)
    end
  end
end

-- Define the Autocmd Group
local window_focus_group = vim.api.nvim_create_augroup('WindowFocusGroup', { clear = true })

-- Set the Autocommands to run the function when focus changes
vim.api.nvim_create_autocmd({ 'VimEnter', 'WinEnter', 'BufRead' }, {
  group = window_focus_group,
  callback = highlight_active_window,
})

-- Also run setup and highlight after colorscheme changes
vim.api.nvim_create_autocmd('ColorScheme', {
  group = window_focus_group,
  callback = function()
    setup_dynamic_colors()
    highlight_active_window()
  end
})

-- Initial call to set the correct color when Neovim starts
setup_dynamic_colors()
highlight_active_window()
