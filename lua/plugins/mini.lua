return {
 'nvim-mini/mini.nvim', version = '*' ,
config = function() 
require('mini.basics').setup()
require('mini.comment').setup()

require('mini.icons').setup()
require('mini.ai').setup()

require('mini.pairs').setup()
require('mini.bracketed').setup()
    end
}
