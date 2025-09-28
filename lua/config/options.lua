local set = vim.opt


-- use OS clipboard
vim.schedule(function()
  vim.o.clipboard = 'unnamedplus'
end)

-- Preview substitutions live, as you type!
vim.o.inccommand = 'split'
-- Minimal number of screen lines to keep above and below the cursor.
vim.o.scrolloff = 10


-- Save undo history
vim.o.undofile = true
set.number = true

set.cursorline = true
set.relativenumber = true

-- indentation and tabs
set.shiftwidth = 4
set.autoindent = true
set.smarttab = true

-- apearance
set.termguicolors = false
set.background = "dark"
set.signcolumn = "yes"


-- cursor line
set.cursorline = false

set.smoothscroll = true		-- enable smooth scrolling
set.mouse = "a" 		--enable mouse
set.showcmd = true

-- Searching
set.ignorecase = true		--ignore case while searching
set.smartcase = true		--but do not ignore if caps are used
set.incsearch = true            -- search as characters are entered
set.hlsearch = false            -- do not highlight matches

