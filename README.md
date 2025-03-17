# buftrack.nvim

## Purpose
Track visited buffers and jump back to them, like `bp`/`bn` but in the order of visit instead of load.

### Motivation
I want to cycle between a few buffers which I constantly edit/visit, but I don't want to actively maintain the tracked buffer list.
Harpoon-likes are too involving to use, while `bp`/`bn` requires too many invocations to find the correct buffer. So `buftrack.nvim`
serves as a middle ground by tracking buffers heuristically.

## Installation
### lazy.nvim
```lua
{
  'bloznelis/buftrack.nvim',
  config = function()
    local buftrack = require('buftrack')
    buftrack.setup()

    -- Not required but recommended. Once you start inserting text,
    -- this will move the current buffer to the top of the tracklist.
    vim.api.nvim_create_autocmd({ "InsertEnter" }, {
      callback = buftrack.track_buffer
    })

    vim.keymap.set("n", "<C-j>", buftrack.prev_buffer)
    vim.keymap.set("n", "<C-k>", buftrack.next_buffer)
  end
}
```

### Available commands
- `:BufTrack` - Move the current buffer to the top of the tracking list
- `:BufTrackPrev` - Opens previous buffer in the tracking list
- `:BufTrackNext` - Opens next buffer in the tracking list
- `:BufTrackList` - Prints the tracking list
- `:BufTrackClear` - Clears the tracking list

### Config
To change defaults:
```lua
buftrack.setup({
  max_tracked = 16 -- Size limit of the buffer tracking list (oldest buffers are dropped)
})
```
