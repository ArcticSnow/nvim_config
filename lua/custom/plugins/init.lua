-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information


local bibtex_finder = require("bibtex_finder")
bibtex_finder.setup({
  bib_file = "~/Zotero/my_library_for_nvim.bib",  -- Optional: Override default path
  citation_format = "[@%s]",                   -- Optional: Change citation format
})

return {}


