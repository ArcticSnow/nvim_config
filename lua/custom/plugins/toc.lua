--- Custom plugin to display and navigate through a Table of Content (ToC)
--- Enhanced with:
--- - Better Python cell support
--- - Breadcrumbs navigation
--- - Folding support
--- - Color coding and symbols for types
--- - Current position indicator
---
--- S. Filhol

local M = {}

-- Define icons and highlight groups for different symbol types
local icons = {
  func = "f ",       -- For functions (avoids 'function' keyword)
  class = "C ",      -- Class
  method = "m ",     -- Method
  heading = "# ",     -- Heading
  cell = "%",      -- Cell
  default = "* "     -- Default
}
local hl_groups = {
  func = "TelescopeResultsFunction",
  class = "TelescopeResultsStruct",
  method = "TelescopeResultsMethod",
  heading = "TelescopeResultsTitle",
  cell = "TelescopeResultsOperator",
  default = "TelescopeResultsNormal"
}

--- Extracts headings from Markdown/Quarto files
---@return table<{line: string, lnum: integer, display: string, level: integer, type: string}>
local function extract_markdown_headings()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local headings = {}
  for lnum, line in ipairs(lines) do
    local level = line:match("^(#+)%s+")
    if level then
      level = #level
      local display = line:gsub("^#+%s*", "")
      table.insert(headings, {
        line = line,
        lnum = lnum,
        display = display,
        level = level,
        type = "heading"
      })
    end
  end
  return headings
end

--- Extracts symbols from Python files
---@return table<{line: string, lnum: integer, display: string, level: integer, type: string}>
local function extract_python_symbols()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local symbols = {}

  for lnum, line in ipairs(lines) do
    -- Check for function/class definitions
    if line:match("^%s*def%s+") then
      local indent = line:match("^%s*") or ""
      local level = #indent / 2 + 1
      local display = line:match("^%s*(.-)%s*$") or line
      table.insert(symbols, {
        line = line,
        lnum = lnum,
        display = display,
        level = level,
        type = "func"
      })
    elseif line:match("^%s*class%s+") then
      local indent = line:match("^%s*") or ""
      local level = #indent / 2 + 1
      local display = line:match("^%s*(.-)%s*$") or line
      table.insert(symbols, {
        line = line,
        lnum = lnum,
        display = display,
        level = level,
        type = "class"
      })
    -- Handle your 4-line cell format: #%% + separator + title + separator
    elseif line:match("^%s*#%%%%%s*$") and lnum + 3 <= #lines then
      local sep_line1 = lines[lnum + 1]
      local title_line = lines[lnum + 2]
      local sep_line2 = lines[lnum + 3]

      local sep1 = sep_line1:match("^%s*#([%=%.%-]+)%s*$")
      local title = title_line:match("^%s*#%s*(.*)")
      local sep2 = sep_line2:match("^%s*#([%=%.%-]+)%s*$")

      if sep1 and title and sep2 and sep1 == sep2 then
        -- Determine level based on separator character
        local level = 1
        if sep1:match("^%-") then
          level = 2  -- dashes for H2
        elseif sep1:match("^%.") then
          level = 3  -- dots for H3
        elseif sep1:match("^=") then
          level = 1  -- equals for H1
        end

        -- Clean title: remove # and trim whitespace
        title = title:gsub("^%s*#?%s*", ""):gsub("%s+$", "")

        table.insert(symbols, {
          line = line .. "\n" .. sep_line1 .. "\n" .. title_line .. "\n" .. sep_line2,
          lnum = lnum + 4,  -- Jump to line after the block
          display = title,
          level = level,
          type = "cell"
        })
      end
    end
  end
  return symbols
end



--- Extracts functions from Lua files
---@return table<{line: string, lnum: integer, display: string, level: integer, type: string}>
local function extract_lua_functions()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local functions = {}
  for lnum, line in ipairs(lines) do
    if line:match("^%s*function%s+") or line:match("^%s*local%s+function%s+") then
      local indent = line:match("^%s*")
      local level = math.floor(#indent / 2) + 1
      table.insert(functions, {
        line = line,
        lnum = lnum,
        display = line:match("^%s*(.-)%s*$") or line,
        level = level,
        type = "function"
      })
    end
  end
  return functions
end

--- Extracts subroutines/functions from Fortran files
---@return table<{line: string, lnum: integer, display: string, level: integer, type: string}>
local function extract_fortran_subroutines()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local subroutines = {}
  for lnum, line in ipairs(lines) do
    if line:lower():match("^%s*subroutine%s+") or line:lower():match("^%s*function%s+") then
      local indent = line:match("^%s*")
      local level = math.floor(#indent / 2) + 1
      table.insert(subroutines, {
        line = line,
        lnum = lnum,
        display = line:match("^%s*(.-)%s*$") or line,
        level = level,
        type = "function"
      })
    end
  end
  return subroutines
end

--- Extracts functions from Julia files
---@return table<{line: string, lnum: integer, display: string, level: integer, type: string}>
local function extract_julia_functions()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local functions = {}
  for lnum, line in ipairs(lines) do
    if line:match("^%s*function%s+") then
      local indent = line:match("^%s*")
      local level = math.floor(#indent / 2) + 1
      table.insert(functions, {
        line = line,
        lnum = lnum,
        display = line:match("^%s*(.-)%s*$") or line,
        level = level,
        type = "function"
      })
    end
  end
  return functions
end

--- Opens a Telescope picker with TOC for the current file
function M.open_toc()
  local filetype = vim.bo.filetype
  local items = {}
  local prompt_title = "Table of Content"

  -- Filetype-specific extraction
  local extractors = {
    markdown = extract_markdown_headings,
    quarto = extract_markdown_headings,
    python = extract_python_symbols,
    lua = extract_lua_functions,
    fortran = extract_fortran_subroutines,
    julia = extract_julia_functions
  }

  local extractor = extractors[filetype]
  if not extractor then
    vim.notify("Unsupported filetype for TOC: " .. filetype, vim.log.levels.WARN)
    return
  end

  items = extractor()
  if #items == 0 then
    vim.notify("No TOC items found.", vim.log.levels.WARN)
    return
  end

  -- Add parent-child relationships for breadcrumbs
  local last_level = 0
  local stack = {}
  for _, item in ipairs(items) do
    -- Pop stack until we find parent
    while #stack > 0 and stack[#stack].level >= item.level do
      table.remove(stack)
    end

    -- Set parent
    if #stack > 0 then
      item.parent = stack[#stack]
    end

    -- Push to stack
    table.insert(stack, item)
  end

  local picker = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")
  local previewers = require("telescope.previewers")
picker.new( {
  prompt_title = prompt_title,
  finder = finders.new_table({
    results = items,
    entry_maker = function(entry)
      local icon = icons[entry.type] or icons.default
      local hl_group = hl_groups[entry.type] or hl_groups.default
      return {
	value = entry,
	display = entry.display,
	-- Use line number as first sort key to preserve order
	ordinal = string.format("%05d-%s", entry.lnum, entry.display),
	lnum = entry.lnum,
	filename = vim.api.nvim_buf_get_name(0),
	bufnr = vim.api.nvim_get_current_buf(),
	level = entry.level,
	type = entry.type,
	hl_group = hl_group,
	icon = icon,
	parent = entry.parent
      }
    end,
  }),
    sorter = conf.generic_sorter({}),
    --sorter = require("telescope.sorting").none,
    previewer = previewers.vim_buffer_vimgrep.new({}),
    -- Custom display with colors, icons, and current position
    entry_display = function(entry)
      local current_line = vim.api.nvim_win_get_cursor(0)[1]
      local indicator = entry.lnum == current_line and "→ " or "  "

      -- Breadcrumbs
      local breadcrumbs = {}
      local current = entry
      while current do
        table.insert(breadcrumbs, 1, current.display)
        current = current.parent
      end
      local breadcrumb_text = #breadcrumbs > 1 and table.concat(breadcrumbs, " > ") .. " > " or ""

      -- Main display
      local icon = icons[entry.type] or icons.default
      local display_text = string.rep("  ", entry.level - 1) .. icon .. entry.display

      return {
        { indicator, "TelescopeResultsSpecialComment" },
        { breadcrumb_text, "TelescopeResultsComment" },
        { display_text, entry.hl_group },
        { " (" .. entry.lnum .. ")", "TelescopeResultsComment" }
      }
    end,
    attach_mappings = function(prompt_bufnr, map)
      -- Jump to selection
      map("i", "<CR>", function()
        local entry = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        if entry then
          vim.api.nvim_win_set_cursor(0, { entry.lnum, 0 })
          vim.cmd("normal! zz")
        end
      end)

      -- Navigation with preview update
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
    -- Folding support
    layout_strategy = 'flex',
    layout_config = {
      preview_cutoff = 1,
      width = 0.4,
      height = 0.8,
      anchor = 'N',
    },
  }):find()
end

return M
