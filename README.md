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

## Installation

To install the current config, we need to first clone the repository, install the terminal emulation Kitty (to work with a Python REPL).

### Add various configuration
The git repository contains three branches split in worktree to be accessible as all time by the copmuter and test anytime new config implementation.
To do so, create the worktree on the local `~/.config/` folder as follow:

```
~/.config/nvim/             ----> master branch
~/.config/nvim-dev/         ----> dev branch
~/.config/nvim-test/        ----> test branch
```

To add worktree, use the command `git worktree add [path to create worktree] [branch]`. For instance, `git ../nvim-dev dev` from the master branch.



In your bashrc create these alias to access the dev and test nvim configuration
```bash
# nvim alias and config
#alias v='nvim'
alias nvim-dev='NVIM_CONFIG=~/.config/nvim-dev NVIM_DATA=~/.local/share/nvim-dev nvim'
alias nvim-test='NVIM_CONFIG=~/.config/nvim-test NVIM_DATA=~/.local/share/nvim-test nvim'

# small interactive prompt to pick the nvim config
vv() {
  select config in main dev test
  do NVIM_CONFIG=~/.config/nvim-$config NVIM_DATA=~/.local/share/nvim-$config nvim $@; break; done
}
```

### Add Kitty terminal REPL for Nvim

1. install kitty terminal (https://sw.kovidgoyal.net/kitty/)
2. in the kitty config file add: map kitty_mod+f2 detach_window

```
map kitty_mod+f4 detach_window ask
map kitty_mod+r start_resizing_window

# see hlp below. Allows running terminal from nvim
allow_remote_control yes
listen_on unix:@mykitty
enabled_layouts tall,stack

# Keymap for interacting in between nvim and kitty windoe seamlessly, using the plugin:  https://github.com/knubie/vim-kitty-navigator
map ctrl+j kitten pass_keys.py bottom ctrl+j
map ctrl+k kitten pass_keys.py top    ctrl+k
map ctrl+h kitten pass_keys.py left   ctrl+h
map ctrl+l kitten pass_keys.py right  ctrl+l

```

3. Install in neovim the plugin:  https://github.com/knubie/vim-kitty-navigator



