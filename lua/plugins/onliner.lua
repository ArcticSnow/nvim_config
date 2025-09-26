return {
    {
	-- SSH yank  cd
	'ojroques/vim-oscyank',

},
   -- show keybinding help window
  {
    'folke/which-key.nvim',
    enabled = true,
    config = function()
      require('which-key').setup {}
      require 'config.keybinds'
    end,
  },   
}
