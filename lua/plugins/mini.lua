return {
{ 'nvim-mini/mini.nvim', version = '*' },

    require('mini.basics').setup()
require('mini.comment').setup()

require('mini.ai').setup()

require('mini.pairs').setup()
require('mini.bracketed').setup()
}
