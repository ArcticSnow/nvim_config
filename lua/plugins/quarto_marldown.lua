return {
  { -- requires plugins in lua/plugins/treesitter.lua and lua/plugins/lsp.lua
    -- for complete functionality (language features)
    'quarto-dev/quarto-nvim',
    ft = { 'quarto' },
    dev = false,
    opts = {},
    dependencies = {
      -- for language features in code cells
      -- configured in lua/plugins/lsp.lua and
      -- added as a nvim-cmp source in lua/plugins/completion.lua
      'jmbuhr/otter.nvim',
    },
  },
  -- { -- highlight markdown headings and code blocks etc.
  --   'lukas-reineke/headlines.nvim',
  --   enabled = true,
  --   dependencies = 'nvim-treesitter/nvim-treesitter',
  --   config = function()
  --     require('headlines').setup {
  --       quarto = {
  --         query = vim.treesitter.query.parse(
  --           'markdown',
  --           [[
  --               (fenced_code_block) @codeblock
  --               ]]
  --         ),
  --         codeblock_highlight = 'CodeBlock',
  --         treesitter_language = 'markdown',
  --       },
  --       markdown = {
  --         query = vim.treesitter.query.parse(
  --           'markdown',
  --           [[
  --               (fenced_code_block) @codeblock
  --               ]]
  --         ),
  --         codeblock_highlight = 'CodeBlock',
  --       },
  --     }
  --   end,
  -- },
  {
    'MeanderingProgrammer/render-markdown.nvim',
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.nvim' }, -- if you use the mini.nvim suite
    ft = { 'markdown', 'quarto' },
    heading = { border = true },
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.icons' }, -- if you use standalone mini plugins
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {},
  },
}
