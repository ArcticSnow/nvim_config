# README

My NeoVim configuration. 

TODO:
- [ ] add AI agent
- [x] make a command to move from code block next/previous in quarto file
- [ ] make window borders a bit more obvious. 
- [ ] Have the non-active windows of a slightly altered shade
- [ ] improve the "six" method to send code block to REPL bringing back the cursor to th same position
- [ ] make the "six" method work while being in insert mode to

## Keymap

### Buffers

- `<tab>` - Move to next buffer
- `<S-tab>` - Move to previous buffer
- `<leader>bd` - Close current buffer without changing window layout
- `<leader>rm` - delete current file, send it to Trash

### Quarto

- `<leader>cn` - jump to next code block
- `<leader>cb` - jump to previous code block
- `<leader>cc` - insert a python codeblock
- `<leader>cs` - split a python codeblock

Using MiniNvim, a codeblock textobject has a keymap of `x`

### Terminal

- `<leader>tv` - Open terminal with a vertical split window
- `<leader>th` - Open terminal with a horizontal split window 
- `<leader>tr` - Open terminal in current window
- `s` - send lines to terminal (normal and visual modes)
- `<A-s>` - send current line to terminal in `insert` mode
- `six` - send current codeblock to terminal

### Telescope

- `<leader>ff` - find files in current working Directory
- `<leader>fg` - fuzzy find files in working directory
- `<leader>fb` - find open buffers
- `<leader>fh` - open telescope help
- `<leader>fm` - fuzzy find files in github directory
- `<leader>fo` - fuzzy find files in Obsidian vault
- `<leader>fp` - fuzzy find files in PAPROG directory (specific to work computer)


### quickfix






