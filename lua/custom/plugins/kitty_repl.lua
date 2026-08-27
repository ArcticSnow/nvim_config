--- ===============================================================
--    Kitty REPL terminal 
--
--     Author: gulogulo
--     Date: 2026-03-13
--
-- ================================================================
-- TODO:
--
-- ================================================================
-- -- Custom plugin to interact with kitty terminal, and emulate a REPL terminal in between nvim and kitty terminal
--
-- A lightweight module to open and send code to a REPL terminal. 
-- 
-- Specific functions for sending Python code to a Kitty terminal REPL.
-- Supports both visual selection and code block execution via #%% markers or ```python``` in Quarto and Markdown files.
--
-- FEATURES
-- --------
-- - Send current line, visual selection, or motion-based selection to REPL
-- - Detect Python code blocks separated by #%% markers
-- - Fallback to TreeSitter for markdown code blocks
-- - Maintains REPL connection across sessions
--
-- INSTALLATION
-- ------------
-- 1. Add to your Neovim config (e.g., `lua/plugins/kitty-repl.lua`)
-- 2. Requires: Kitty terminal
-- 3. 



local M = {}
 
M.current_repl = nil  -- Stores { id = number, type = "window" }
 
---
--- Start a new Kitty terminal window.
---
M.new_repl = function()
  M.current_repl = tonumber(vim.fn.system('kitty @ launch --type window --cwd current --title repl'))
end
 
 
 
---
--- Open a new Kitty window with an IPython REPL (using the 'generic' profile)
--- in Neovim's current working directory, using the active Python virtual environment.
---
M.new_python_repl = function()
  local profile = "science"
  local ipython_path
  local cwd = vim.fn.getcwd()  -- Use buffer's directory or fall back to CWD
 
  -- Try to get the virtual environment path
  local venv_path
  if vim.g.python3_host_prog and vim.g.python3_host_prog ~= "" then
    venv_path = vim.g.python3_host_prog:match("^(.*/)[^/]+$")
  else
    venv_path = os.getenv("VIRTUAL_ENV")
  end
 
  -- If a venv is detected, check if it has IPython
  if venv_path then
    ipython_path = venv_path .. "/bin/ipython"
    if vim.fn.filereadable(ipython_path) ~= 1 then
      ipython_path = nil  -- IPython not in venv
    end
  end
 
  -- Fall back to global IPython if venv lacks it
  if not ipython_path then
    ipython_path = vim.fn.executable("ipython") == 1 and "ipython" or nil
  end
 
  -- Final fallback to Python if IPython is missing
  if not ipython_path then
    ipython_path = "python"
    profile = nil  -- No profile for plain Python
  end
 
  -- Build the command: executable + profile flag (if applicable)
  local cmd_parts = { ipython_path }
  if profile then
    table.insert(cmd_parts, "--profile=" .. profile)
  end
 
  -- Escape each part individually and join with spaces
  local escaped_cmd = ""
  for i, part in ipairs(cmd_parts) do
    if i > 1 then
      escaped_cmd = escaped_cmd .. " "
    end
    escaped_cmd = escaped_cmd .. vim.fn.shellescape(part)
  end
 
  -- Launch Kitty with the correct CWD and command
  M.current_repl = tonumber(vim.fn.system(
    string.format(
      'kitty @ launch --type window --cwd %s --title ipython-%s %s',
      vim.fn.shellescape(cwd),
      profile or "default",
      escaped_cmd
    )
  ))
end
 
 
 
---
--- Check if a Python process is running in the current REPL window.
--- Uses pure Lua JSON parsing (no external dependencies like `jq`).
---
--- `kitty @ ls` returns a NESTED structure: a list of OS windows, each with
--- a list of tabs, each with a list of kitty windows. It is NOT a flat list
--- of windows, so we have to descend into `tabs[].windows[]` to find the one
--- matching M.current_repl.
---
--- We check `foreground_processes` (what's currently running in the pane)
--- rather than the window's original launch `pid`/`comm`, because if the
--- window was opened as a plain shell (M.new_repl) and ipython/python was
--- started manually afterwards, the launch PID would still resolve to the
--- shell, never to python.
---
M.is_python_running_in_repl = function()
  if not M.current_repl then
    return false
  end
 
  local output = vim.fn.system('kitty @ ls')
  local ok, os_windows = pcall(vim.json.decode, output)
  if not ok then
    vim.notify("Failed to decode `kitty @ ls` output", vim.log.levels.ERROR)
    return false
  end
 
  for _, os_window in ipairs(os_windows) do
    for _, tab in ipairs(os_window.tabs or {}) do
      for _, win in ipairs(tab.windows or {}) do
        if win.id == M.current_repl then
          for _, proc in ipairs(win.foreground_processes or {}) do
            local cmd = proc.cmdline and proc.cmdline[1] or ""
            -- matches "python", "python3", "ipython", etc.
            if cmd:match("python") then
              return true
            end
          end
          return false
        end
      end
    end
  end
 
  return false
end
 
--- Send text to the REPL, with optional language check.
--- @param text string: The text to send.
--- @param language string|nil: The language of the code (defaults to current buffer's filetype).
---
M.send = function(text, language)
  -- Default to the current buffer's filetype if no language is provided
  language = language or vim.bo.filetype
 
  -- Only check for Python if the language is Python
  if language == "python" and not M.is_python_running_in_repl() then
    vim.notify(
      "No Python console is running in the terminal. Start it manually first.",
      vim.log.levels.WARN
    )
    return
  end
 
  -- Original send logic
  text = text:gsub('[\r\n]+', '\n'):gsub('\n%s*\n', '\n'):gsub('^\n+', ''):gsub('\n+$', ''):gsub('\n', '\\n'):gsub('"', '\\"')
  vim.fn.system(string.format('kitty @ send-text --match id:%s "%s"', M.current_repl, text .. '\\n\\n'))
end
 
---
--- Send the current line to the REPL.
---
M.send_line = function()
  local pos = vim.fn.getpos('.')
  local lines = vim.api.nvim_buf_get_lines(0, pos[2] - 1, pos[2], false)
  local content = table.concat(lines, '\n')
  M.send(content)
end
 
---
--- Send the visual selection to the REPL.
---
M.send_visual = function()
  vim.cmd.normal({ '"zy', bang = true })
  local selection = vim.fn.getreg('z')
  M.send(selection)
end
 
---
--- Send text from a motion to the REPL.
---
M.send_motion = function(motion)
  local start_pos = vim.api.nvim_buf_get_mark(0, '[')
  local end_pos = vim.api.nvim_buf_get_mark(0, ']')
  local lines = vim.api.nvim_buf_get_lines(0, start_pos[1] - 1, end_pos[1], false)
  if #lines == 0 then
    return
  end
  lines[1] = string.sub(lines[1], start_pos[2] + 1)
  lines[#lines] = string.sub(lines[#lines], 1, end_pos[2] + 1)
  local content = table.concat(lines, '\n')
  M.send(content)
end
 
---
--- Extract text from a range.
---
local function extract_text(r_start, c_start, r_end, c_end)
  local line = vim.api.nvim_buf_get_lines(0, r_start, r_start + 1, false)[1]
  return string.sub(line, c_start + 1, c_end + 1)
end
 
---
--- Parse Python code blocks from the buffer.
---
local function get_python_codeblocks()
  local codeblocks = {}
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local current_block = { start = 1, content = {} }
  local in_block = false
 
  for i, line in ipairs(lines) do
    if line:match('^%s*#%%%s*$') then
      if in_block then
        table.insert(codeblocks, {
          language = 'python',
          executable_content = table.concat(current_block.content, '\n'),
          start_line = current_block.start,
          end_line = i - 1
        })
        current_block = { start = i + 1, content = {} }
      else
        in_block = true
        current_block.start = i + 1
      end
    else
      if in_block then
        table.insert(current_block.content, line)
      end
    end
  end
 
  if in_block and #current_block.content > 0 then
    table.insert(codeblocks, {
      language = 'python',
      executable_content = table.concat(current_block.content, '\n'),
      start_line = current_block.start,
      end_line = #lines
    })
  end
 
  return codeblocks
end
 
---
--- Get code blocks from the buffer (Python, Markdown, or Quarto).
---
M.get_codeblocks = function(start, stop, max_blocks)
  local codeblocks = {}
  if vim.bo.filetype == 'python' then
    codeblocks = get_python_codeblocks()
  elseif vim.bo.filetype == 'qmd' or vim.bo.filetype == 'md' then
    local parser = vim.treesitter.get_parser(0, 'markdown')
    local tree = parser:parse()[1]
    local query = vim.treesitter.query.parse(
      'markdown',
      [[
        (fenced_code_block
          (info_string (language) @language) @info
          (code_fence_content) @content)
      ]]
    )
    local num_blocks = 0
    for pattern, match, metadata in query:iter_matches(tree:root(), 0, start, stop) do
      num_blocks = num_blocks + 1
      if max_blocks ~= nil and num_blocks > max_blocks then
        break
      end
      local row_start, _, row_end, _ = match[3][1]:range()
      local lines = vim.api.nvim_buf_get_lines(0, row_start, row_end, false)
      local text = table.concat(lines, '\n')
      local node_language = match[1][1]
      local language = extract_text(node_language:range())
      table.insert(codeblocks, { language = language, executable_content = text })
    end
  end
  return codeblocks
end
 
---
--- Format a code block for sending to the REPL.
---
local function format_codeblock(codeblock_idx, codeblock)
  return string.format(
    "## Code block %d (language: %s):\n%s\n\n",
    codeblock_idx,
    codeblock.language,
    codeblock.executable_content
  )
end
 
---
--- Send all code blocks before the cursor to the REPL.
---
M.send_codeblocks_before_cursor = function()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local codeblocks = M.get_codeblocks(0, row)
  for codeblock_idx, codeblock in ipairs(codeblocks) do
    M.send(format_codeblock(codeblock_idx, codeblock), codeblock.language)
  end
end
 
---
--- Send the current code block to the REPL.
---
M.send_current_codeblock = function()
  local row, _ = unpack(vim.api.nvim_win_get_cursor(0))
  local codeblocks = M.get_codeblocks(0, row + 1, 1)  -- Get only the current block
 
  if #codeblocks > 0 then
    M.send(format_codeblock(1, codeblocks[1]), codeblocks[1].language)
  else
    -- If no codeblock found, send current line instead
    M.send_line()
  end
end
 
return M
 
