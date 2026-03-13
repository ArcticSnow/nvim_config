-- =================================================================================
--      Templater: Small plugin to insert templates using telescope
--
-- Author: S. Filhol
-- Date: 2026-03-13
-- ================================================================================
--
-- A lightweight Neovim plugin for inserting file templates using Telescope.
--
-- FEATURES
-- --------
-- - Insert templates into new or existing buffers.
-- - Dynamic placeholder replacement (%{date}, %{author}, etc.).
-- - Telescope integration for easy template selection.
-- - Optional autocommand to trigger on new files.
--
-- USAGE
-- -----
-- 1. Place your template files in `~/.config/nvim/templates/` (e.g., `python.py`, `quarto.qmd`).
-- 2. Call `require("templates").pick(require("templates").insert)` to open the template picker.
-- 3. (Optional) Uncomment the autocommand in this file to auto-trigger for new files.
--
-- KEYMAP (example for your keymap.lua):
-- --------------------------------------
-- ```lua
-- vim.keymap.set("n", "<leader>t", function() require("templates").pick(require("templates").insert) end, {
--   noremap = true, silent = true, desc = "Insert template",
-- })
--
-- =======================================================================================

local M = {}

-- Path to your templates directory
M.template_dir = vim.fn.expand("~/.config/nvim/templates/")

-- Function to list all template files
local function get_templates()
  local files = {}
  local handle = io.popen("ls " .. M.template_dir)
  if handle then
    for file in handle:lines() do
      table.insert(files, file)
    end
    handle:close()
  end
  return files
end

-- Function to read a template file
local function read_template(filename)
  local path = M.template_dir .. filename
  local file = io.open(path, "r")
  if not file then return {} end
  local content = file:read("*a")
  file:close()
  return vim.split(content, "\n")
end

-- Telescope picker for templates
M.pick = function(callback)
  require("telescope.pickers").new({}, {
    prompt_title = "Select Template",
    finder = require("telescope.finders").new_table({
      results = get_templates(),
    }),
    sorter = require("telescope.config").values.generic_sorter(),
    attach_mappings = function(prompt_bufnr)
      require("telescope.actions").select_default:replace(function()
        local selection = require("telescope.actions.state").get_selected_entry()
        require("telescope.actions").close(prompt_bufnr)
        callback(selection[1])
      end)
      return true
    end,
  }):find()
end

-- Function to insert the selected template
M.insert = function(template_name)
  local lines = read_template(template_name)
  if #lines > 0 then
    -- Replace placeholders
    local replaced = {}
    for _, line in ipairs(lines) do
      line = line:gsub("%%{date}", os.date("%Y-%m-%d"))
      line = line:gsub("%%{author}", vim.env.USER or "Your Name")
      line = line:gsub("%%{script_name}", vim.fn.expand("%:t"))
      line = line:gsub("%%{purpose}", "Describe the purpose of this script")
      table.insert(replaced, line)
    end
    vim.api.nvim_buf_set_lines(0, 0, -1, false, replaced)
  end
end

-- -- Autocommand to trigger template picker for new files (optional)
-- vim.api.nvim_create_autocmd("BufNewFile", {
--   pattern = "*",
--   callback = function()
--     if vim.fn.line("$") == 1 and vim.fn.getline(1) == "" then
--       -- M.pick(M.insert)  -- Uncomment to enable auto-trigger
--     end
--   end,
-- })



return M
