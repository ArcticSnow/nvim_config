-- ===============================================================
--     Docstring: A small module to generate automatically Python definition Docstring
--
--     Author: S. Filhol & LeChat
--     Date: 2026-03-14
--
-- ================================================================
--
-- PYTHON DOCSTRING GENERATOR
--
-- Automatically generates Google-style docstrings for Python functions.
--
-- ## Features
-- - Generates properly indented Google-style docstrings
-- - Extracts function parameters and their types
-- - Detects return type annotations
-- - Places cursor in description field for easy editing
-- - Preserves existing function code
--
--
-- ================================================================



local M = {}

-- Default configuration
M.config = {
  indent = 4,
  default_type = 'Any',
  include_types = true,
  template = [[
"""%s

Args:
%s

Returns:
    %s: %s
"""
  ]]
}

--- Setup configuration
---@param config table Configuration options
M.setup = function(config)
  M.config = vim.tbl_deep_extend("force", M.config, config or {})
end

--- Extract function parameters from signature
---@return table List of parameter info tables
local function extract_params()
  local line = vim.api.nvim_get_current_line()
  local params_str = line:match("def %w+%((.*)%)") or ""  -- Fixed: :match instead of ()
  local params = {}

  for param in params_str:gmatch("[^,]+") do  -- Fixed: :gmatch instead of ()
    param = param:gsub("^%s+", ""):gsub("%s+$", "")  -- Fixed: :gsub instead of ()
    if param ~= "" then
      local name = param:match("^(%w+)") or ""  -- Fixed: :match instead of ()
      local type_hint = param:match(":%s*(%S+)") or M.config.default_type  -- Fixed: :match instead of ()
      table.insert(params, {
        name = name,
        type = M.config.include_types and type_hint or ""
      })
    end
  end
  return params
end

--- Extract return type annotation
---@return string Return type or default
local function extract_return_type()
  local line = vim.api.nvim_get_current_line()
  local return_type = line:match("->%s*(%S+)") or M.config.default_type  -- Fixed: :match instead of ()
  return M.config.include_types and return_type or ""
end

--- Generate parameter documentation lines
---@param params table List of parameter info
---@return string Formatted parameter docs
local function generate_param_docs(params)
  local lines = {}
  local indent = string.rep(" ", M.config.indent)
  for _, param in ipairs(params) do
    local type_str = param.type ~= "" and string.format(" (%s): ", param.type) or ": "
    table.insert(lines, string.format("%s%s%s", indent, param.name, type_str))
  end
  return table.concat(lines, "\n")
end

--- Main function to generate docstring

M.generate = function()
  -- Verify Python file
  if vim.bo.filetype ~= "python" then
    vim.notify("Not in a Python file", vim.log.levels.WARN)
    return
  end

  -- Check cursor position
  local line = vim.api.nvim_get_current_line()
  if not line:match("^%s*def ") then
    vim.notify("Cursor not on function definition", vim.log.levels.WARN)
    return
  end

  -- Get the indentation of the current line and add one level deeper
  local def_indent = line:match("^%s*"):len()
  local indent_str = string.rep(" ", def_indent)
  local content_indent = indent_str .. string.rep(" ", M.config.indent)

  -- Check for existing docstring
  local next_line = vim.api.nvim_buf_get_lines(0, vim.api.nvim_win_get_cursor(0)[1], vim.api.nvim_win_get_cursor(0)[1] + 1, false)[1] or ""
  if next_line:match('^%s*""".-"""') or next_line:match('^%s*""".-') then
    vim.notify("Docstring already exists", vim.log.levels.WARN)
    return
  end

  -- Extract function info
  local params = extract_params()
  local return_type = extract_return_type()

  -- Generate parameter documentation lines
  local param_docs = generate_param_docs(params)

  -- Generate docstring lines with proper indentation
  local docstring_lines = {
    content_indent .. '"""[DESCRIPTION]',
    content_indent .. 'Args:'
  }

  -- Add parameter documentation
  for _, param_line in ipairs(vim.split(param_docs, "\n")) do
    table.insert(docstring_lines, content_indent .. param_line)
  end

  -- Add returns section
  table.insert(docstring_lines, content_indent .. 'Returns:')
  table.insert(docstring_lines, content_indent .. '    ' .. return_type .. ': [RETURN DESCRIPTION]')
  table.insert(docstring_lines, content_indent .. '"""')

  -- Insert docstring line by line
  local row = vim.api.nvim_win_get_cursor(0)[1]
  vim.api.nvim_buf_set_lines(0, row, row, false, docstring_lines)

  -- Position cursor in the description field with proper indentation
  vim.api.nvim_win_set_cursor(0, {row + 1, def_indent + M.config.indent + 1})
  vim.cmd("startinsert")
end

return M

