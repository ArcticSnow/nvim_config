--- Custom plugin to display a Table of Content (ToC) of the file
--- Coded with the help of LeChat, Mistral
--- S. Filhol
---
--- TODO:
---  - [ ] exclude python code block from parsing for markdown and quarto files.
---  - [ ] add color to telescope results 
---


local M = {}

-- Define highlight groups for different levels
local hl_groups = {
  [1] = "TelescopeResultsIdentifier", -- Level 1 (e.g., #, def, function)
  [2] = "TelescopeResultsFunction",   -- Level 2
  [3] = "TelescopeResultsStruct",     -- Level 3
  [4] = "TelescopeResultsVariable",   -- Level 4
}

--- Extracts headings from Markdown/Quarto files
---@return table<{line: string, lnum: integer, display: string, level: integer}>
local function extract_markdown_headings()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local headings = {}
  for lnum, line in ipairs(lines) do
    local level = line:match("^(#+)%s+")
    if level then
      level = #level
      local display = line:gsub("^#+%s*", "")
      table.insert(headings, { line = line, lnum = lnum, display = display, level = level })
    end
  end
  return headings
end

--- Extracts symbols from Python files
---@return table<{line: string, lnum: integer, display: string, level: integer}>
local function extract_python_symbols()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local symbols = {}

  for lnum, line in ipairs(lines) do
    -- Check for function/class definitions
    if line:match("^%s*def%s+") or line:match("^%s*class%s+") then
      local indent = line:match("^%s*") or ""
      local level = #indent / 2 + 1  -- Assuming 2 spaces per indentation level
      local display = line:match("^%s*(.-)%s*$") or line
      table.insert(symbols, {
        line = line,
        lnum = lnum,
        display = display,
        level = level
      })
    -- Check for cell separator pattern (#%% followed by #)
    elseif  line:match("^%s*%#%%%%%s*") and
           lines[lnum + 1]:match("^%s*%#%s*%-%-%-") then
      local indent = line:match("^%s*") or ""
      local level = #indent / 2 + 1
      local display = lines[lnum + 1]
      table.insert(symbols, {
        line = line,
        lnum = lnum,
        display = display,
        level = level
      })
    end
  end

  return symbols
end

--- Extracts functions from Lua files
---@return table<{line: string, lnum: integer, display: string, level: integer}>
local function extract_lua_functions()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local functions = {}
  for lnum, line in ipairs(lines) do
    if line:match("^%s*function%s+") or line:match("^%s*local%s+function%s+") then
      local indent = line:match("^%s*")
      local level = math.floor(#indent / 2) + 1
      table.insert(functions, { line = line, lnum = lnum, display = line:match("^%s*(.-)%s*$") or line, level = level })
    end
  end
  return functions
end

--- Extracts subroutines/functions from Fortran files
---@return table<{line: string, lnum: integer, display: string, level: integer}>
local function extract_fortran_subroutines()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local subroutines = {}
  for lnum, line in ipairs(lines) do
    if line:lower():match("^%s*subroutine%s+") or line:lower():match("^%s*function%s+") then
      local indent = line:match("^%s*")
      local level = math.floor(#indent / 2) + 1
      table.insert(subroutines, { line = line, lnum = lnum, display = line:match("^%s*(.-)%s*$") or line, level = level })
    end
  end
  return subroutines
end

--- Extracts functions from Julia files
---@return table<{line: string, lnum: integer, display: string, level: integer}>
local function extract_julia_functions()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local functions = {}
  for lnum, line in ipairs(lines) do
    if line:match("^%s*function%s+") then
      local indent = line:match("^%s*")
      local level = math.floor(#indent / 2) + 1
      table.insert(functions, { line = line, lnum = lnum, display = line:match("^%s*(.-)%s*$") or line, level = level })
    end
  end
  return functions
end

--- Opens a Telescope picker with TOC for the current file
function M.open_toc()
  local filetype = vim.bo.filetype
  local items = {}
  local prompt_title = "Table of Content"

  if  filetype == "markdown" or filetype == "quarto" then
    items = extract_markdown_headings()
    prompt_title =  filetype:upper() .. "file ToC"
  elseif  filetype == "python" then
    items = extract_python_symbols()
    prompt_title = "Python file ToC"
  elseif  filetype == "lua" then
    items = extract_lua_functions()
    prompt_title = "Lua file ToC"
  elseif  filetype == "fortran" then
    items = extract_fortran_subroutines()
    prompt_title = "Fortran file ToC"
  elseif  filetype == "julia" then
    items = extract_julia_functions()
    prompt_title = "Julia file ToC"
  else
    vim.notify("Unsupported  filetype forfile ToC: " .. filetype, vim.log.levels.WARN)
    return
  end

  if #items == 0 then
    vim.notify("Nofile ToC items found.", vim.log.levels.WARN)
    return
  end

  local picker = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")
  local previewers = require("telescope.previewers")
  local themes = require("telescope.themes")

  picker.new(themes.get_ivy(), {
    prompt_title = prompt_title,
    finder = finders.new_table({
      results = items,
      entry_maker = function(entry)
        local display_text = string.rep("  ", entry.level - 1) .. entry.display
        local hl_group = hl_groups[math.min(entry.level, 4)]
        return {
          value = entry,
          display = display_text,
          ordinal = entry.display,
          lnum = entry.lnum,
          filename = vim.api.nvim_buf_get_name(0),
          bufnr = vim.api.nvim_get_current_buf(),
          level = entry.level,
          hl_group = hl_group,
        }
      end,
    }),
    sorter = conf.generic_sorter({}),
    previewer = previewers.vim_buffer_vimgrep.new({}),
    -- Custom display function to apply highlight and indentation
    entry_display = function(entry)
      local indent = { string.rep("  ", entry.level - 1), "TelescopeResultsComment" }
      local display = { entry.display, entry.hl_group }
      local lnum = { " (" .. entry.lnum .. ")", "TelescopeResultsComment" }
      return { indent, display, lnum }
    end,
    attach_mappings = function(prompt_bufnr, map)
      map("i", "<CR>", function()
        local entry = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        if entry then
          vim.api.nvim_win_set_cursor(0, { entry.lnum, 0 })
          vim.cmd("normal! zz")
        end
      end)
      -- Update preview on movement
      map("i", "<C-j>", function()
        local entry = action_state.get_selected_entry()
        if entry then
          local previewer = action_state.get_current_picker(prompt_bufnr).previewer
          pcall(function()
            previewer.state.last_entry = entry
            previewer:scroll_fn(entry.lnum)
          end)
        end
        return actions.move_selection_next(prompt_bufnr)
      end)
      map("i", "<C-k>", function()
        local entry = action_state.get_selected_entry()
        if entry then
          local previewer = action_state.get_current_picker(prompt_bufnr).previewer
          pcall(function()
            previewer.state.last_entry = entry
            previewer:scroll_fn(entry.lnum)
          end)
        end
        return actions.move_selection_previous(prompt_bufnr)
      end)
      return true
    end,
  }):find()
end

return M
