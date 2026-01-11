# bufstack.nvim

A neovim plugin to cycle through recently used order and reopen recently closed buffers.

## Features

- Tracks recently used and recently closed buffers.
- Lists tracked buffers in a menu (`BufStackList`, `BufClosedList`).
- Navigates through tracked buffers (`BufStackNext`, `BufStackPrev`).
- Reopens closed buffers (`BufReopen`).
- Clears tracked and closed buffers (`BufStackClear`, `BufClosedClear`, `BufClear`).
- Telescope integration for reopening closed buffers (`BufStackTelescope`).
- Resession integration for persisting buffer state across sessions.

## Usage

### Installation

Using lazy.nvim:

```lua
return {
    'BibekBhusal0/bufstack.nvim',
    dependencies = {
        'MunifTanjim/nui.nvim',        -- optional: required for menu
        'nvim-lua/plenary.nvim',       -- optional: required to shorten path
        'nvim-telescope/telescope.nvim', -- optional: required for telescope picker
        'stevearc/resession.nvim'      -- optional: for session persistence
    },
    opts = {
        max_tracked = 16,
        shorten_path = true
    }
}
```

### Configuration

```lua
require('bufstack').setup({
  max_tracked = 16, -- Default: 16
  shorten_path = true, -- Default: false
  telescope_config = { -- Default: see below
    sorting_strategy = 'ascending',
    layout_config = {
      prompt_position = 'top',
      width = function(_, max_columns, _)
        return math.min(max_columns, 80)
      end,
      height = function(_, _, max_lines)
        return math.min(max_lines, 20)
      end,
    },
  }
})
```

### Resession Integration

To persist buffer state across sessions, use the resession extension:

```lua
require("resession").setup(extensions = {
  bufstack = {}
})
```

### Commands

- `BufStack`: Tracks the current buffer.
- `BufStackNext`: Navigates to the next tracked buffer.
- `BufStackPrev`: Navigates to the previous tracked buffer.
- `BufStackList`: Lists tracked buffers in a menu.
- `BufClosedList`: Lists recently closed buffers in a menu.
- `BufStackTelescope`: Lists recently closed buffers in telescope.
- `BufReopen`: Reopens the last closed buffer.
- `BufStackClear`: Clears the list of tracked buffers.
- `BufClosedClear`: Clears the list of closed buffers.
- `BufClear`: Clears both tracked and closed buffers lists.

### Key Mappings (Example)

```lua
vim.keymap.set('n', '<leader>bn', '<Cmd>BufStackNext<CR>')
vim.keymap.set('n', '<leader>bp', '<Cmd>BufStackPrev<CR>')
vim.keymap.set('n', '<leader>bl', '<Cmd>BufStackList<CR>')
vim.keymap.set('n', '<leader>br', '<Cmd>BufReopen<CR>')
vim.keymap.set('n', '<leader>bt', '<Cmd>BufStackTelescope<CR>')
```

### Keymaps in Menu

Menu of tracked buffer and recently closed buffers can be opened with commands `BufStackList` and `BufClosedList` respectively.

Keymaps in the menu are:

- j and arrow down for next item
- k and arrow up for previous item
- enter or space to select item
- esc or q to close menu
- d to remove item from list
- D to remove all items from list
- t to move item to the top of the list
- x to close buffer (only in tracked buffer menu)

### Keymaps in Telescope

Telescope picker can be opened with `BufStackTelescope` command.

Keymaps in telescope are:

- d to remove item from list
- D to clear all closed buffers
- t to move item to the top of the list

## Dependencies

- [nui.nvim](https://github.com/MunifTanjim/nui.nvim) (optional)
- [plenary.nvim](https://github.com/nvim-lua/plenary.nvim) (optional)
- [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) (optional)
- [resession.nvim](https://github.com/stevearc/resession.nvim) (optional)

## Credits

- [buftrack](https://github.com/bloznelis/buftrack.nvim)
- [memento](https://github.com/gaborvecsei/memento.nvim/tree/master)
- [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)

## License

MIT
