
return {
    'nvim-telescope/telescope.nvim', tag = '0.1.8',
    -- or                              , branch = '0.1.x',
    dependencies = { 
	'nvim-lua/plenary.nvim',
	{'nvim-telescope/telescope-fzf-native.nvim', build='make'}
    },
    config = function()
	require('telescope').setup{
	    pickers = {
		find_files = {  theme = "ivy"},
		live_grep = {theme = "ivy"},
		buffers = {theme = "ivy"},
		help_tags = {theme = "ivy"},
	    }}

	require('telescope').load_extension('fzf')

	-- option to access neovim config files from anywhere using telescope
	vim.keymap.set("n", "<space>fn", function()
	    require('telescope.builtin').find_files {
		cwd = vim.fn.stdpath("config")
	    }
	end,
	    {desc = "Telescope nvim config files"}
	)	


	local builtin = require('telescope.builtin')
	vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
	vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
	vim.keymap.set('n', '<leader>b', builtin.buffers, { desc = 'Telescope buffers' })
	vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })

	-- findout logic to have a shortcut to search my local folder /github. Try to find how to only include certain type of text ('.txt, .md, .qmd, .ipynb, .py, .html, .css, .cpp, .h, .f95, .f77, .csv, )


	-- Function to fuzzy search a specific folder with file extension filtering
	-- @param dir (string): The path to the folder to search.
	-- @param extensions (table): A table of file extensions to include (e.g., {'md', 'txt', 'lua'}).
	function live_grep_with_extensions(dir, extensions)
	    local telescope = require('telescope.builtin')
	    local path = vim.fn.expand(dir)

	    -- Check if the directory exists
	    if vim.fn.isdirectory(path) == 0 then
		print('Error: Directory ' .. path .. ' not found.')
		return
	    end

	    -- Construct the glob patterns for ripgrep
	    local patterns = {}
	    for _, ext in ipairs(extensions) do
		table.insert(patterns, '*.' .. ext)
	    end

	    -- Use ripgrep's --iglob flag to filter files
	    local glob_args = {}
	    for _, pattern in ipairs(patterns) do
		table.insert(glob_args, '--glob')
		table.insert(glob_args, pattern)
	    end

	    telescope.live_grep({
		-- Specify the directory to start the search from
		cwd = path,
		-- Pass the glob arguments to ripgrep
		additional_args = glob_args,
		-- Set the prompt title
		prompt_title = 'Live Grep in ' .. path,
	    })
	end

	-- Shortcut to search within my Github folder
	vim.keymap.set('n', '<leader>fm', function()
	    live_grep_with_extensions('~/github', {'txt', 'md', 'qmd', 'ipynb', 'py', 'cpp', 'h', 'f95', 'f77'})
	end, { desc = 'Ripgrep search in files in my local github folder' })

	-- Shortcut to search within my Obsidian vault (on MF computer)
	vim.keymap.set('n', '<leader>fo', function()
	    live_grep_with_extensions('~/Documents/MF_vault/', {'md'})
	end, { desc = 'Ripgrep search in my Obsidian vault' })

	-- Shortcut to search within my PAPROG folder (on MF computer)
	vim.keymap.set('n', '<leader>fp', function()
	    live_grep_with_extensions('~/PAPROG/', {'txt', 'md', 'qmd', 'ipynb', 'py', 'cpp', 'h', 'f95', 'f77'})
	end, { desc = 'Ripgrep search in my PAPROG folder' })
    end
}
