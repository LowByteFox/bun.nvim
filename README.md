# bun.nvim

## NeoVim plugin for Bun JavaScript runtime

This plugin adds `Bun` subcommand and shows `node_modules.bun` and `bun.lockb` files

# Installation 

### use your favorite package manager

Examples: <br>

using `packer`
```lua
use('akinsho/toggleterm.nvim') -- this is a must!
use('Fire-The-Fox/bun.nvim')
```

<br>

using `vim-plug`
```vim
Plug 'akinsho/toggleterm.nvim' " this is a must!
Plug 'Fire-The-Fox/bun.nvim'
```

# Configuring

```lua
require("bun").setup({
    close_on_exit = true | false, -- if the terminal window should close instantly after bun exited
    cwd = "current" | "relative", -- run_current's working directory
    -- if "current" it will use current working directory of NeoVim
    -- if "relative" it will use directory where the file is located
    direction = "horizontal" | "float" -- float will create floating window and horizontal will put it under buffers 
})
```

# API

### API is still not finished, but you can bind run_current as a keybinding to neovim

```lua
local bun = require("bun")

-- setup it your way
bun.setup({})

-- in my case <leader> is spacebar, so i hit "spacebar + b + r" and it will run current file
vim.keymap.set("n", "<leader>br", bun.run_current)
```
