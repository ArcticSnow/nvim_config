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

  -- Precompute a breadcrumb string per item by walking its parent chain once
  for _, item in ipairs(items) do
    local crumbs = {}
    local current = item.parent
    while current do
      table.insert(crumbs, 1, current.display)
      current = current.parent
    end
    item.breadcrumb = #crumbs > 0 and (table.concat(crumbs, " > ") .. " > ") or ""
  end

  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")
  local previewers = require("telescope.previewers")
  local entry_display = require("telescope.pickers.entry_display")

  -- Cap the breadcrumb column so long nesting doesn't push everything off-screen
  local max_breadcrumb = 0
  for _, item in ipairs(items) do
    max_breadcrumb = math.max(max_breadcrumb, #item.breadcrumb)
  end
  max_breadcrumb = math.min(max_breadcrumb, 40)

  -- Build the displayer ONCE (outside entry_maker) — this is what was missing.
  -- It returns a function that assembles colored segments into one display string.
  local displayer = entry_display.create({
    separator = "",
    items = {
      { width = 2 },              -- current-position indicator
      { width = max_breadcrumb }, -- breadcrumb trail
      { remaining = true },       -- indent + icon + title + (lnum)
    },
  })

  local function make_display(entry)
    local current_line = vim.api.nvim_win_get_cursor(0)[1]
    local indicator = entry.lnum == current_line and "→ " or "  "
    local indent = string.rep("  ", entry.level - 1)
    local body = indent .. entry.icon .. entry.title .. " (" .. entry.lnum .. ")"

    return displayer({
      { indicator, "TelescopeResultsSpecialComment" },
      { entry.breadcrumb, "TelescopeResultsComment" },
      { body, entry.hl_group },
    })
  end

  local picker = pickers.new({}, {
    prompt_title = prompt_title,
    -- Fixes the reversed ordering: makes item #1 render at the top of the list.
    sorting_strategy = "ascending",

    finder = finders.new_table({
      results = items,
      entry_maker = function(item, index)
        local icon = icons[item.type] or icons.default
        local hl_group = hl_groups[item.type] or hl_groups.default
        return {
          value = item,
          -- Search by title text instead of by row index, so typing filters meaningfully.
          ordinal = item.breadcrumb .. item.display,
          lnum = item.lnum,
          filename = vim.api.nvim_buf_get_name(0),
          bufnr = vim.api.nvim_get_current_buf(),
          level = item.level,
          type = item.type,
          hl_group = hl_group,
          icon = icon,
          title = item.display,
          breadcrumb = item.breadcrumb,
          -- IMPORTANT: display must be a function that returns (string, highlights)
          -- when you want per-segment coloring. A plain string can't be colored.
          display = make_display,
        }
      end,
    }),
    -- Use Telescope's built-in sorter
    sorter = conf.generic_sorter({}),

    previewer = previewers.vim_buffer_vimgrep.new({}),
    attach_mappings = function(prompt_bufnr, map)
      map("i", "<CR>", function()
        local entry = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        if entry then
          vim.api.nvim_win_set_cursor(0, { entry.lnum, 0 })
          vim.cmd("normal! zz")
        end
      end)
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
    layout_strategy = 'flex',
    layout_config = {
      preview_cutoff = 1,
      width = 0.4,
      height = 0.8,
      anchor = 'N',
    },
  })
  picker:find()
end

return M
