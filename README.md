# README

My NeoVim configuration. 

TODO:
- [x] make a command to move from code block next/previous in quarto file
- [ ] make window borders a bit more obvious. 
- [x] Have the non-active windows of a slightly altered shade
- [ ] improve the "six" method to send code block to REPL bringing back the cursor to th same position
- [ ] make the "six" method work while being in insert mode to
- [ ] review bibtex insert code

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

- `<leader>tt` - Open terminal with a vertical split window
- `s` - send lines to terminal (normal and visual modes)
- `<A-s>` - send current line to terminal in `insert` mode
- `six` - send current codeblock to terminal

### Telescope

#### Classical use of telescope

- `<leader>ff` - find files in current working Directory
- `<leader>fg` - fuzzy find files in working directory
- `<leader>fb` - find open buffers
- `<leader>fh` - open telescope help
- `<leader>fm` - fuzzy find files in github directory
- `<leader>fo` - fuzzy find files in Obsidian vault
- `<leader>fp` - fuzzy find files in PAPROG directory (specific to work computer)

#### Custom made plugins using telescope 

- `<leader>ft` - display and navigate the file table of content in telescope to 
- `<leader>tm` - insert a file template. Templates located in .config/nvim/template
- `<leader>bb` - search and insert bibtex reference from the Zotero library in a quarto file

### Docstring

- `<leader>dc` - generate Python docstring (Google style)


### quickfix






