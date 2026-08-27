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
-- - Multiple REPLs: each project (cwd) is bound to its own kitty REPL
--   window, so any buffer in that project sends to the same REPL
-- - Bracketed-paste sends so multi-line blocks (loops, defs, etc.) don't
--   desync indentation or get cut short by a blank line
--
-- INSTALLATION
-- ------------
-- 1. Add to your Neovim config (e.g., `lua/plugins/kitty-repl.lua`)
-- 2. Requires: Kitty terminal
-- 3. 


local M = {}

-- All REPLs this session knows about, keyed by kitty window id.
-- Each entry: { id = number, title = string, cwd = string }
M.repls = {}

-- Which repl id each project is currently bound to: { [cwd] = repl_id }
M.cwd_repl = {}

---
--- The "project" a buffer belongs to, for REPL-binding purposes. Uses the
--- effective cwd for the current window (respects :lcd/:tcd if set, falls
--- back to the global cwd otherwise), so all buffers opened under the same
--- project directory share one REPL.
---
local function get_project_cwd()
  return vim.fn.getcwd(0)
end

-- Bracketed-paste escape codes. Wrapping a multi-line send in these tells
-- the terminal app (ipython/python's readline/prompt_toolkit) to treat the
-- whole block as a single paste rather than line-by-line keystrokes, which
-- is what causes autoindent double-indenting and blank-line block breakage.
local BP_START = '\27[200~'
local BP_END = '\27[201~'

---
--- Flatten `kitty @ ls` (os_windows -> tabs -> windows) into a plain list
--- of window objects. Reflects ALL kitty windows currently open, not just
--- ones this Neovim session launched, so you can reattach to a REPL that
--- was started before Neovim (or before a restart).
---
local function list_kitty_windows()
  local output = vim.fn.system('kitty @ ls')
  if vim.v.shell_error ~= 0 then
    return {}
  end
  local ok, os_windows = pcall(vim.json.decode, output)
  if not ok then
    return {}
  end
  local windows = {}
  for _, os_window in ipairs(os_windows) do
    for _, tab in ipairs(os_window.tabs or {}) do
      for _, win in ipairs(tab.windows or {}) do
        table.insert(windows, win)
      end
    end
  end
  return windows
end

---
--- Find a single kitty window object by id (nil if not found / kitty
--- window has been closed).
---
local function find_kitty_window(id)
  for _, win in ipairs(list_kitty_windows()) do
    if win.id == id then
      return win
    end
  end
  return nil
end

---
--- Record a repl's metadata and bind it to a project cwd (defaults to the
--- current project cwd).
---
local function register_repl(id, title, cwd)
  if not id then
    return nil
  end
  cwd = cwd or get_project_cwd()
  M.repls[id] = { id = id, title = title, cwd = cwd }
  M.cwd_repl[cwd] = id
  return id
end

---
--- Get the repl id bound to the current project (cwd), or nil if none.
---
M.get_current_repl = function()
  return M.cwd_repl[get_project_cwd()]
end

---
--- Print (via vim.notify) which repl the current project (cwd) is bound to.
--- Handy sanity check when juggling several REPLs across projects.
---
M.repl_status = function()
  local cwd = get_project_cwd()
  local id = M.cwd_repl[cwd]
  if not id then
    vim.notify('No REPL bound to project: ' .. cwd, vim.log.levels.INFO)
    return
  end
  local info = M.repls[id]
  local win = find_kitty_window(id)
  if not win then
    vim.notify(string.format('Project %s bound to REPL %d, but that kitty window no longer exists.', cwd, id), vim.log.levels.WARN)
    return
  end
  vim.notify(string.format(
    'Project %s -> REPL %d (%s)',
    cwd,
    id,
    win.title or (info and info.title) or '?'
  ), vim.log.levels.INFO)
end

---
--- Let the user pick which kitty window the current project's REPL
--- commands go to. Lists every kitty window currently open (not just ones
--- tracked in M.repls), so this also works for reattaching after
--- restarting Neovim, or for pointing two projects at the same REPL.
---
M.select_repl = function()
  local windows = list_kitty_windows()
  if #windows == 0 then
    vim.notify('No kitty windows found.', vim.log.levels.WARN)
    return
  end

  vim.ui.select(windows, {
    prompt = 'Select REPL window for ' .. get_project_cwd() .. ':',
    format_item = function(win)
      local tracked = M.repls[win.id] and '  [tracked]' or ''
      local cwd_hint = win.cwd and ('  (' .. win.cwd .. ')') or ''
      return string.format('%d: %-20s (pid %s)%s%s', win.id, win.title or '?', tostring(win.pid), cwd_hint, tracked)
    end,
  }, function(choice)
    if not choice then
      return
    end
    -- Bind to the current project cwd, regardless of the kitty window's
    -- own cwd -- what matters here is which project you want it to serve.
    register_repl(choice.id, choice.title, get_project_cwd())
    vim.notify('Bound project ' .. get_project_cwd() .. ' to REPL ' .. choice.id, vim.log.levels.INFO)
  end)
end

---
--- Short, human-friendly project label from a cwd: just the last path
--- component, e.g. "/home/me/projects/foo" -> "foo". Used to make REPL
--- window titles identifiable at a glance in kitty's tab bar and in
--- select_repl()'s picker.
---
local function project_name(cwd)
  local name = vim.fn.fnamemodify(cwd, ':t')
  return name ~= '' and name or cwd
end

---
--- Rename an existing kitty window. We can't know a window's id until
--- AFTER `kitty @ launch` returns it, so any title that needs to include
--- the id gets set here, as a second step, rather than via `--title` at
--- launch time.
---
local function set_kitty_title(id, title)
  local result = vim.fn.system({ 'kitty', '@', 'set-window-title', '--match', 'id:' .. tostring(id), title })
  if vim.v.shell_error ~= 0 then
    vim.notify('Failed to set REPL window title: ' .. result, vim.log.levels.WARN)
  end
end

---
--- Start a new Kitty terminal window and bind it to the current project.
--- The window is renamed after launch to "repl#<id>:<project>" so it's
--- identifiable in kitty's tab bar and in select_repl()'s picker.
---
M.new_repl = function()
  local cwd = get_project_cwd()
  local id = tonumber(vim.fn.system('kitty @ launch --type window --cwd current --title repl'))
  if not id then
    vim.notify('Failed to launch kitty REPL window.', vim.log.levels.ERROR)
    return
  end
  local title = string.format('repl#%d:%s', id, project_name(cwd))
  set_kitty_title(id, title)
  register_repl(id, title, cwd)
end



---
--- Locate a Python virtualenv/conda env for a given project directory.
---   1. A local venv folder inside cwd (.venv, venv, .env, env)
---   2. $CONDA_PREFIX -- the active conda env in the shell that launched
---      Neovim. Conda doesn't set $VIRTUAL_ENV, so this needs its own check.
---   3. $VIRTUAL_ENV -- the venv active in the shell that launched Neovim
---      (this is what most LSP setups auto-detect too)
---   4. python3_host_prog -- LOWEST priority on purpose: this is commonly
---      pinned to a separate venv dedicated to Neovim's own :python3
---      provider, unrelated to whatever project you're working in. Trusting
---      it first is what caused new_python_repl() to ignore an actually-
---      active project venv.
--- Returns the venv root (no trailing slash) and a short label saying
--- where it came from, or nil, nil if nothing was found.
---
local function find_venv_path(cwd)
  local candidates = { '.venv', 'venv', '.env', 'env' }
  for _, name in ipairs(candidates) do
    local path = cwd .. '/' .. name
    if vim.fn.isdirectory(path .. '/bin') == 1 then
      return path, 'local folder ' .. name
    end
  end

  local conda_prefix = os.getenv("CONDA_PREFIX")
  if conda_prefix and conda_prefix ~= "" then
    return conda_prefix, 'CONDA_PREFIX'
  end

  local env_venv = os.getenv("VIRTUAL_ENV")
  if env_venv and env_venv ~= "" then
    return env_venv, 'VIRTUAL_ENV'
  end

  if vim.g.python3_host_prog and vim.g.python3_host_prog ~= "" then
    -- python3_host_prog points at the interpreter itself, e.g.
    -- ".../.venv/bin/python3" -- strip "/bin/<exe>" to get the venv root.
    local dir = vim.g.python3_host_prog:match("^(.*)/bin/[^/]+$")
    if dir then
      return dir, 'python3_host_prog'
    end
  end

  return nil, nil
end

---
--- Open a new Kitty window with an IPython REPL (using the 'generic' profile)
--- in Neovim's current working directory. Prefers a venv local to the
--- current project, then $CONDA_PREFIX, then $VIRTUAL_ENV, then
--- python3_host_prog, then a global interpreter (see find_venv_path).
--- Binds the new window to the current project (cwd).
---
M.new_python_repl = function()
  local profile = "science"
  local ipython_path
  local cwd = get_project_cwd()

  local venv_path, venv_source = find_venv_path(cwd)

  -- If a venv is detected, check if it has IPython
  if venv_path then
    ipython_path = venv_path .. "/bin/ipython"
    if vim.fn.filereadable(ipython_path) ~= 1 then
      vim.notify(
        string.format('Found venv via %s (%s) but no ipython there -- falling back.', venv_source, venv_path),
        vim.log.levels.WARN
      )
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

  vim.notify(
    string.format('Launching %s%s', ipython_path, venv_path and (' (venv via ' .. venv_source .. ': ' .. venv_path .. ')') or ' (no venv detected)'),
    vim.log.levels.INFO
  )

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
  local id = tonumber(vim.fn.system(
    string.format(
      'kitty @ launch --type window --cwd %s --title %s %s',
      vim.fn.shellescape(cwd),
      vim.fn.shellescape('repl'),
      escaped_cmd
    )
  ))
  if not id then
    vim.notify('Failed to launch kitty IPython REPL window.', vim.log.levels.ERROR)
    return
  end

  -- "ipython-science#3:myproject" if we launched ipython with a profile,
  -- "python#4:myproject" if we fell all the way back to plain python.
  local exe_label = ipython_path:match('ipython') and ('ipython-' .. (profile or 'default')) or 'python'
  local title = string.format('%s#%d:%s', exe_label, id, project_name(cwd))
  set_kitty_title(id, title)
  register_repl(id, title, cwd)
end



---
--- Check if a Python process is running in the given (or current project's)
--- REPL window. Checks `foreground_processes` (what's actually running in
--- the pane right now) rather than the window's original launch pid, so it
--- still works if Python/IPython was started manually after the window was
--- opened as a plain shell.
---
--- @param repl_id number|nil: defaults to the repl bound to the current project (cwd).
---
M.is_python_running_in_repl = function(repl_id)
  repl_id = repl_id or M.get_current_repl()
  if not repl_id then
    return false
  end

  local win = find_kitty_window(repl_id)
  if not win then
    return false
  end

  for _, proc in ipairs(win.foreground_processes or {}) do
    local cmd = proc.cmdline and proc.cmdline[1] or ""
    if cmd:match("python") then  -- matches "python", "python3", "ipython", etc.
      return true
    end
  end
  return false
end

--- Send text to the REPL bound to the current project (cwd), with optional
--- language check. Multi-line sends are wrapped in bracketed-paste escapes
--- so indentation-sensitive blocks (loops, defs, decorators, blank lines
--- inside a block) survive the trip intact.
--- @param text string: The text to send.
--- @param language string|nil: The language of the code (defaults to current buffer's filetype).
---
M.send = function(text, language)
  language = language or vim.bo.filetype
  local repl_id = M.get_current_repl()

  if not repl_id then
    vim.notify(
      "No REPL bound to this project. Run new_repl(), new_python_repl(), or select_repl() first.",
      vim.log.levels.WARN
    )
    return
  end

  -- Only check for Python if the language is Python
  if language == "python" and not M.is_python_running_in_repl(repl_id) then
    vim.notify(
      "No Python console is running in the terminal. Start it manually first.",
      vim.log.levels.WARN
    )
    return
  end

  text = text:gsub('[\r\n]+', '\n'):gsub('\n%s*\n', '\n'):gsub('^\n+', ''):gsub('\n+$', ''):gsub('\n', '\\n')

  -- The trailing newline(s) must come AFTER the paste-end marker, not
  -- before it. Bracketed paste exists precisely so a shell/REPL can tell
  -- "this newline was part of a paste" from "this newline is an Enter
  -- keypress" -- newlines *inside* the paste don't auto-submit. Put them
  -- inside and you get exactly what you saw: code fills the prompt but
  -- needs a manual Enter. Two newlines after BP_END covers REPLs (plain
  -- python) that need a blank line to close an indented block.
  local payload = BP_START .. text .. BP_END .. '\\n\\n'

  -- Pass as a table (argv), not a formatted shell string: avoids shell
  -- interpretation of $, `, \, etc. inside the code being sent, and lets
  -- the raw ESC bytes in BP_START/BP_END reach kitty untouched.
  local result = vim.fn.system({
    'kitty', '@', 'send-text',
    '--match', 'id:' .. tostring(repl_id),
    payload,
  })
  if vim.v.shell_error ~= 0 then
    vim.notify('kitty send-text failed: ' .. result, vim.log.levels.ERROR)
  end
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
--- Send the visual selection to the REPL. Restores the previous contents
--- of register "z" afterwards so this doesn't clobber the user's register.
---
M.send_visual = function()
  local saved_z = vim.fn.getreg('z')
  local saved_z_type = vim.fn.getregtype('z')

  vim.cmd.normal({ '"zy', bang = true })
  local selection = vim.fn.getreg('z')
  M.send(selection)

  vim.fn.setreg('z', saved_z, saved_z_type)
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
