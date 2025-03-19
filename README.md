# buftrack.nvim

A neovim plugin to cycle through recently used order and reopen recently closed buffers.

## Features

- Tracks recently used and recently closed buffers.
- Lists tracked buffers in a menu (`BufTrackList`, `BufClosedList`).
- Navigates through tracked buffers (`BufTrackNext`, `BufTrackPrev`).
- Reopens closed buffers (`BufReopen`).
- Clears tracked and closed buffers (`BufTrackClear`, `BufClosedClear`, `BufClear`).

## Usage

### Installation

Using lazy.nvim:

```lua
return {
    'BibekBhusal0/buftrack.nvim',
    dependencies = { 'MunifTanjim/nui.nvim' }, -- required if you want to use menu
    opts = { max_tracked = 16 }
}
```

### Configuration

```lua
require('buftrack').setup({
  max_tracked = 16, -- Default: 16
})
```

### Commands

- `BufTrack`: Tracks the current buffer.
- `BufTrackNext`: Navigates to the next tracked buffer.
- `BufTrackPrev`: Navigates to the previous tracked buffer.
- `BufTrackList`: Lists tracked buffers in a menu.
- `BufClosedList`: Lists recently closed buffers in a menu.
- `BufReopen`: Reopens the last closed buffer.
- `BufTrackClear`: Clears the list of tracked buffers.
- `BufClosedClear`: Clears the list of closed buffers.
- `BufClear`: Clears both tracked and closed buffers lists.

### Key Mappings (Example)

```lua
vim.keymap.set('n', '<leader>bn', '<Cmd>BufTrackNext<CR>')
vim.keymap.set('n', '<leader>bp', '<Cmd>BufTrackPrev<CR>')
vim.keymap.set('n', '<leader>bl', '<Cmd>BufTrackList<CR>')
vim.keymap.set('n', '<leader>br', '<Cmd>BufReopen<CR>')
```

### Keymaps in Menu

Menu of tracked buffer and recently closed buffers can be opened with commands `BufTrackList` and `BufClosedList` respectively.

Keymaps in the menu are:

- j and arrow down for next item
- k and arrow up for previous item
- enter or space to select item
- esc or q to close menu
- d to remove item from list
- D to remove all items from list
- t to move item to the top of the list
- x to close buffer (only in tracked buffer menu)

## Dependencies

- [nui.nvim](https://github.com/MunifTanjim/nui.nvim)

## Credits

- [bloznelis](https://github.com/bloznelis/buftrack.nvim)

## License

MIT
