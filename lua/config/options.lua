-- ================================================================================================
-- TITLE : NeoVim options
-- ABOUT : basic settings native to neovim
-- ================================================================================================

local set = vim.opt

-- Basic configs
set.number = true
set.cursorline = true
set.relativenumber = true

-- use OS clipboard
vim.schedule(function()
  vim.o.clipboard = 'unnamedplus'
end)


-- Preview substitutions live, as you type!
vim.o.inccommand = 'split'
-- Minimal number of screen lines to keep above and below the cursor.
-- set.scrolloff = 10
set.sidescrolloff = 8 			-- Keep 10 line left or right of cursor
set.backspace = "indent,eol,start"	-- Make backspace behave naturally
set.wrap = true 			-- wrap lines 
set.breakindent = true			-- when wrapping, respect indentation
set.breakindentopt = 'shift:4'		-- add visual indent 
set.linebreak = true			-- wrap at words end only
set.spelllang = { "en", "fr" } -- Set language for spellchecking

-- Save undo history
set.undofile = true
set.autoread = true 		-- Auto-reload file is changed outside
set.swapfile = false 		-- do not create swap files
set.backup = false 		-- do not create backup
set.writebackup = false 	-- do not create backup before overwriting


-- indentation and tabs
set.shiftwidth = 4
set.autoindent = true
set.smarttab = true
set.smartindent = false -- Smart auto-indenting

-- appearance
set.termguicolors = false
set.background = "dark"
set.signcolumn = "yes"
set.termguicolors = true 				-- Enable 24-bit colors

-- folding (use by default treesitter)
set.foldmethod = "expr"   				-- use expression for folding 
set.foldexpr = "v:lua.vim.treesitter.foldexpr()"   	-- use treesitter for folding
set.foldlevelstart = 99
set.foldlevel = 20 					-- Keep all folds open by default
set.foldenable = false
set.foldcolumn = "auto:9"

set.wildignorecase = true 	-- Case-insensitive tab completion in commands

-- cursor line
set.cursorline = true

set.smoothscroll = true		-- enable smooth scrolling
set.mouse = "a" 		--enable mouse
set.showcmd = true

-- Searching
set.ignorecase = true		--ignore case while searching
set.smartcase = true		--but do not ignore if caps are used
set.incsearch = true            -- search as characters are entered
set.hlsearch = true            -- do not highlight matches

-- Split behavior
set.splitbelow = true 		-- Horizontal splits open below
set.splitright = true 	-- Vertical splits open to the right


