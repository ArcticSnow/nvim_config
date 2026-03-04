-- Collection of snippets to use with mini.snippets
--
--
-- ~/.config/nvim/lua/snippets.lua
local snippets = require('mini.snippets')

-- Python snippets
snippets.add_snippets('python', {
  docstring = {
    output = {
      '"""',
      'Description: $1',
      '',
      'Args:',
      '    $2',
      '',
      'Returns:',
      '    $3',
      '"""',
    },
  },
})


