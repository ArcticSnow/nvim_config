-- File: /home/simonfi/.config/nvim/lua/config/window_focus.lua

-- Require the utility module
local color_utils = require('custom.plugins.color_utils')

-- Highlight groups for aggressive winhighlight
local ACTIVE_WHL = 'Normal:ActiveWindow,LineNr:ActiveWindow,EndOfBuffer:ActiveWindow,VertSplit:ActiveBorder'
local INACTIVE_WHL = 'Normal:InactiveWindow,LineNr:InactiveWindow,EndOfBuffer:InactiveWindow,VertSplit:InactiveBorder'

-- Define global variables for the calculated colors
local ACTIVE_BG = nil
local INACTIVE_BG = nil
local ACTIVE_FG = nil -- Theme's default foreground
local INACTIVE_FG = nil -- Dimmed foreground

local function to_hex(number)
  return string.format("#%06x", number)
end

local function setup_dynamic_colors()
  -- 1. Read the theme's default Normal colors
  local hl = vim.api.nvim_get_hl_by_name('Normal', true)
  
  local theme_bg = to_hex(hl.background)
  local theme_fg = to_hex(hl.foreground)
  
  -- 2. Calculate dynamic colors
  INACTIVE_BG = color_utils.lighten(theme_bg, 0.1) -- 5% lighter background for active window
  ACTIVE_BG = theme_bg -- Theme's default background for inactive window
  
  INACTIVE_FG = theme_fg -- Theme's default foreground for active window
  ACTIVE_FG = color_utils.darken(theme_fg, 0.20) -- 20% darker foreground for inactive window
  
  -- 3. Redefine the highlight groups with dynamic colors
  -- Active Window: Background is 5% lighter, Foreground is theme's default.
  vim.cmd("highlight ActiveWindow guibg=" .. ACTIVE_BG .. " guifg=" .. ACTIVE_FG)
  
  -- Inactive Window: Background is default, Foreground is 20% darker (dimmed text).
  vim.cmd("highlight InactiveWindow guibg=" .. INACTIVE_BG .. " guifg=" .. INACTIVE_FG)
  
  -- Re-define border colors using hardcoded Tokyo Night colors
 -- vim.cmd([[highlight ActiveBorder guifg=#7aa2f7 ctermfg=75]])   -- Vibrant Blue
 -- vim.cmd([[highlight InactiveBorder guifg=#545c7e ctermfg=239]]) -- Dark Gray
end

local function highlight_active_window()
  -- Ensure colors are set before running the loop
  if not ACTIVE_BG then
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

-- Your autocmd logic to ensure execution on start and colorscheme change
local window_focus_group = vim.api.nvim_create_augroup('WindowFocusGroup', { clear = true })

vim.api.nvim_create_autocmd({ 'VimEnter', 'WinEnter', 'BufRead' }, {
  group = window_focus_group,
  callback = highlight_active_window,
})

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
