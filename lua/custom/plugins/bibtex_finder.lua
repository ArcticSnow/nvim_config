-- ===============================================================
--     MyPlugin: Add here a onliner description
--
--     Author: gulogulo
--     Date: 2026-03-13
--
-- ================================================================
-- TODO:
-- - [ ] review code.
-- - [ ] add title in results after key
-- - [ ] parse other bibtext fields
--
-- ================================================================
--
--
-- Documentation:
-- """"""""""""""
--
-- A plugin for searching and inserting BibTeX references using Telescope.
--
-- FEATURES
-- --------
-- - Search through your BibTeX reference library
-- - Fuzzy search across citation keys, authors, titles, and years
-- - Preview full BibTeX entries before insertion
-- - Insert citations in Quarto/Markdown format ([@key])
-- - Handles multi-line BibTeX entries
-- - Displays keys with year suffix (e.g., smith_2023)
--
-- REQUIREMENTS
-- ------------
-- - Neovim 0.7+
-- - Telescope.nvim installed
-- - A BibTeX file (default: ~/.config/nvim/data/zotero.bib)
--
-- INSTALLATION
-- ------------
-- 1. Save this file as `bibtex_finder.lua` in your Neovim config
-- 2. Add to your init.lua:
--    ```lua
--    local bibtex_finder = require("bibtex_finder")
--    bibtex_finder.setup({
--      bib_file = "path/to/your/references.bib",
--      citation_format = "[@%s]"  -- Quarto/Markdown citation format
--    })
-- 3. Export from Zotero, the library using the plugin BetterBibtex, than can continue to update the .bib file as new items are added to Zotero
--
--
-- ================================================================


-- ~/.config/nvim/lua/bibtex_finder.lua
-- Plugin for inserting BibTeX references in Quarto files
-- Respects Quarto's YAML bibliography field with relative path support
-- Falls back to interactive selection if needed

local M = {}

-- Default configuration
M.config = {
  bib_file = nil,          -- Will be determined automatically
  citation_format = "[@%s]", -- Format for citations
  auto_refresh = true,     -- Whether to auto-refresh references
}

--- Setup function to override defaults
---@param user_config table Configuration options
M.setup = function(user_config)
  M.config = vim.tbl_deep_extend("force", M.config, user_config or {})
end

--- Get bib file path from Quarto YAML header
--- Supports relative paths (e.g., "references.bib" or "../my_refs.bib")
---@return string|nil Path to bib file or nil if not found
local function get_quarto_bib_path()
  -- Only check if current buffer is a Quarto file
  if vim.bo.filetype ~= "quarto" then return nil end

  local lines = vim.api.nvim_buf_get_lines(0, 0, 10, false) -- Check first 10 lines for YAML

  for _, line in ipairs(lines) do
    local trimmed = line:gsub("^%s+", ""):gsub("%s+$", "")

    -- Check for bibliography: field
    if trimmed:match("^bibliography:") then
      local bib_name = trimmed:match("bibliography:%s*(.*)") or ""

      if bib_name ~= "" then
        local file_dir = vim.fn.fnamemodify(vim.fn.expand("%:p"), ":h")

        -- Handle relative paths
        if not vim.startswith(bib_name, "/") then
          -- If it's just a filename (like "references.bib"), prepend current directory
          if not bib_name:match("/") then
            return file_dir .. "/" .. bib_name
          else
            -- Handle relative paths like "../my_refs.bib"
            return file_dir .. "/" .. bib_name
          end
        else
          -- Absolute path
          return bib_name
        end
      end
    end
  end

  return nil
end

--- Check if file exists and is readable
---@param filepath string Path to check
---@return boolean
local function file_exists(filepath)
  local file = io.open(filepath, "r")
  if file then
    file:close()
    return true
  end
  return false
end

--- Change the bib file at runtime
---@param new_path string Path to the new bib file
---@return boolean success
M.change_bib_file = function(new_path)
  if file_exists(new_path) then
    M.config.bib_file = new_path
    vim.notify("BibTeX file changed to: " .. vim.fn.fnamemodify(new_path, ":t"), vim.log.levels.INFO)
    return true
  else
    vim.notify("BibTeX file not found: " .. new_path, vim.log.levels.ERROR)
    return false
  end
end

--- Interactive selection of bib file
M.select_bib_file = function()
  require("telescope.builtin").find_files({
    prompt_title = "Select BibTeX File",
    find_command = { "find", vim.fn.getcwd(), "-name", "*.bib", "-type", "f" },
    previewer = true,
    layout_config = { height = 0.8, width = 0.8 },
    attach_mappings = function(_, map)
      map("i", "<CR>", function(prompt_bufnr)
        local selection = require("telescope.actions.state").get_selected_entry()
        require("telescope.actions").close(prompt_bufnr)
        if selection then
          M.change_bib_file(selection[1])
        end
      end)
      return true
    end,
  })
end

--- Extract field from BibTeX entry
---@param entry string BibTeX entry
---@param field_name string Field to extract (e.g., "title", "author")
---@return string
local function extract_field(entry, field_name)
  local pattern1 = field_name .. '={([^}]*)}'
  local pattern2 = field_name .. '="([^"]*)"'
  return entry:match(pattern1) or entry:match(pattern2) or ""
end

--- Parse the BibTeX file and extract entries
---@param filepath string Path to bib file
---@return table List of entries with metadata
local function parse_bibtex_file(filepath)
  if not file_exists(filepath) then
    vim.notify("BibTeX file not found: " .. filepath, vim.log.levels.ERROR)
    return {}
  end

  local file = io.open(filepath, "r")
  if not file then
    vim.notify("Failed to open BibTeX file: " .. filepath, vim.log.levels.ERROR)
    return {}
  end

  local content = file:read("*a")
  file:close()

  if #content == 0 then
    vim.notify("BibTeX file is empty: " .. filepath, vim.log.levels.WARN)
    return {}
  end

  local entries = {}
  local current_entry = nil

  for line in content:gmatch("[^\n]+") do
    line = line:gsub("^%s+", ""):gsub("%s+$", "")

    if line == "" then
      if current_entry then
        table.insert(entries, current_entry)
        current_entry = nil
      end
      goto continue
    end

    if line:match("^@%a+") then
      if current_entry then
        table.insert(entries, current_entry)
      end

      current_entry = {
        raw = line,
        key = line:match("@%a+{(.-),") or line:match("@%a+{(.-)}") or "unknown",
        title = "No title",
        year = "n.d.",
        author = "",
        full = line,
        entry_type = line:match("^@(%a+)") or "unknown"
      }
      current_entry.key = current_entry.key:gsub(" ", "")
    elseif current_entry then
      current_entry.full = current_entry.full .. "\n" .. line
    end

    ::continue::
  end

  if current_entry then
    table.insert(entries, current_entry)
  end

  -- Process entries
  local processed_entries = {}
  for _, entry in ipairs(entries) do
    local title = extract_field(entry.full, "title")
    local year = extract_field(entry.full, "year")
    local author = extract_field(entry.full, "author")

    local display_key = entry.key
    if year and year ~= "" then
      display_key = entry.key .. "_" .. year
    end

    table.insert(processed_entries, {
      key = display_key,
      original_key = entry.key,
      title = title,
      author = author,
      year = year,
      full = entry.full,
      search_text = string.format("%s %s %s %s", entry.key, author, title, year)
    })
  end

  return processed_entries
end

--- Open Telescope to search and insert BibTeX references
M.search_and_insert = function()
  -- Determine bib file path
  local bib_path = M.config.bib_file

  if not bib_path or not file_exists(bib_path) then
    -- Try to get from Quarto YAML
    local quarto_bib = get_quarto_bib_path()
    if quarto_bib and file_exists(quarto_bib) then
      bib_path = quarto_bib
      M.config.bib_file = bib_path
    else
      -- Interactive selection if no valid bib file
      M.select_bib_file()
      return
    end
  end

  local entries = parse_bibtex_file(bib_path)
  if not entries or #entries == 0 then
    vim.notify("No BibTeX entries found in " .. bib_path, vim.log.levels.WARN)
    return
  end

  require("telescope.pickers").new({}, {
    prompt_title = "Zotero References",
    finder = require("telescope.finders").new_table({
      results = entries,
      entry_maker = function(entry)
        return {
          value = entry,
          display = string.format("%s: %s", entry.key, entry.title),
          ordinal = entry.search_text,
        }
      end,
    }),
    sorter = require("telescope.config").values.generic_sorter(),
    attach_mappings = function(prompt_bufnr)
      require("telescope.actions").select_default:replace(function()
        local selection = require("telescope.actions.state").get_selected_entry()
        require("telescope.actions").close(prompt_bufnr)
        local citation = string.format(M.config.citation_format, selection.value.original_key)
        vim.api.nvim_put({ citation }, "c", true, true)
      end)
      return true
    end,
    previewer = require("telescope.previewers").new_buffer_previewer({
      define_preview = function(self, entry)
        vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, vim.split(entry.value.full, "\n"))
        vim.api.nvim_buf_set_option(self.state.bufnr, "filetype", "bib")
      end,
    }),
  }):find()
end

return M
