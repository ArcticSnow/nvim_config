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
local M = {}

-- Default configuration
M.config = {
  bib_file = vim.fn.expand("~/Zotero/my_library_for_nvim.bib"),
  citation_format = "[@%s]",
  auto_refresh = true,
}

--- Setup function to override defaults
M.setup = function(user_config)
  M.config = vim.tbl_deep_extend("force", M.config, user_config or {})
end

--- Check if file exists and is readable
local function file_exists(filepath)
  local file = io.open(filepath, "r")
  if file then
    file:close()
    return true
  end
  return false
end

--- Extract field from BibTeX entry
local function extract_field(entry, field_name)
  local pattern1 = field_name .. '={([^}]*)}'
  local pattern2 = field_name .. '="([^"]*)"'
  return entry:match(pattern1) or entry:match(pattern2) or ""
end

--- Parse the BibTeX file and extract entries
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

  -- Process the file line by line to handle multi-line entries
  for line in content:gmatch("[^\n]+") do
    line = line:gsub("^%s+", ""):gsub("%s+$", "")  -- Trim whitespace

    -- Skip empty lines
    if line == "" then
      if current_entry then
        table.insert(entries, current_entry)
        current_entry = nil
      end
      goto continue
    end

    -- Start of a new entry
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
    -- Continuation of current entry
    elseif current_entry then
      current_entry.full = current_entry.full .. "\n" .. line
    end

    ::continue::
  end

  -- Add the last entry if file doesn't end with empty line
  if current_entry then
    table.insert(entries, current_entry)
  end

  -- Process entries to extract all fields and create display keys
  local processed_entries = {}
  for _, entry in ipairs(entries) do
    -- Extract all fields from the full entry
    local title = extract_field(entry.full, "title")
    local year = extract_field(entry.full, "year")
    local author = extract_field(entry.full, "author")

    -- Create display key with underscore and year
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
      -- Combine all searchable fields for fuzzy search
      search_text = string.format("%s %s %s %s",
        entry.key, author, title, year)
    })
  end

  return processed_entries
end

--- Open Telescope to search and insert BibTeX references
M.search_and_insert = function()
  local entries = parse_bibtex_file(M.config.bib_file)
  if not entries or #entries == 0 then
    vim.notify("No BibTeX entries found in " .. M.config.bib_file, vim.log.levels.WARN)
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
          ordinal = entry.search_text,  -- Use combined fields for fuzzy search
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
