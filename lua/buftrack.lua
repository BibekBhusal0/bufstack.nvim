local M = {}

M.buffers = {}
M.index = 1
M.cycling = false
M.max_tracked = nil
M.closed_buffers =  {}

local remove = function (tb , item, remove_all )
  for i, b in ipairs(tb ) do
    if b == item then
      table.remove(tb , i)
      if not remove_all then break end
    end
  end
end

function M.track_buffer()
  if M.cycling then return end
  local buf = vim.api.nvim_get_current_buf()

  remove( M.buffers , buf  )

  table.insert(M.buffers, buf)
  -- Cap buffer list size
  if #M.buffers > M.max_tracked then
    table.remove(M.buffers, 1)
  end

  M.index = #M.buffers
end

local function bufvalid(bufnr)
  return vim.api.nvim_buf_is_loaded(bufnr)
      and vim.api.nvim_buf_is_valid(bufnr)
      and vim.bo[bufnr].buflisted
      and vim.bo[bufnr].buftype == ""
end

local on_buffer_close = function (args)
  local buf = args.buf

  -- Check if buffer is valid
  if not (bufvalid (buf)) then return end
  local buf_name = vim.api.nvim_buf_get_name(buf)

  remove( M.closed_buffers , buf_name )
  table.insert(M.closed_buffers, buf_name)

  -- Cap buffer list size
  if #M.closed_buffers > M.max_tracked then
    table.remove(M.closed_buffers, 1)
  end
end

function M.reopen_buffer()
  if #M.closed_buffers > 0 then
    local last_closed_buf = table.remove(M.closed_buffers)
    vim.cmd('edit ' .. last_closed_buf)
  else
    print("No closed buffers to reopen.")
  end
end

local function get_valid_buffer(start_index, direction)
  local count = #M.buffers
  local index = start_index
  while index >= 1 and index <= count do
    if bufvalid(M.buffers[index]) then
      return index
    else
      table.remove(M.buffers, index)
      count = math.max(0, M.index - 1)
      M.index = math.max(1, M.index - 1)
      if count == 0 then return nil end
    end
    index = index + direction
  end
  return nil
end

function M.next_buffer()
  if #M.buffers == 0 then return end
  M.cycling = true
  local new_index = get_valid_buffer(M.index + 1, 1)
  if new_index then
    M.index = new_index
    vim.api.nvim_set_current_buf(M.buffers[M.index])
  else
    print("[buftrack.nvim] Reached the latest buffer.")
  end
  M.cycling = false
end

function M.prev_buffer()
  if #M.buffers == 0 then return end
  M.cycling = true
  local new_index = get_valid_buffer(M.index - 1, -1)
  if new_index then
    M.index = new_index
    vim.api.nvim_set_current_buf(M.buffers[M.index])
  else
    print("[buftrack.nvim] Reached the oldest buffer.")
  end
  M.cycling = false
end

local menu_opts = {
  position = "50%",
  size = {
    width = 60,
    height = 20,
  },
  border = {
    style = "single",
    text = {
      top = " Buffers ",
      top_align = "center",
    },
  },
}
local keymap = {
  focus_next = { "j", "<Down>" },
  focus_prev = { "k", "<Up>" },
  close = { "<Esc>", "<C-c>", "q" },
  submit = { "<CR>", "<Space>" },
}

function M.buffers_list ()
  local Menu = require("nui.menu")
  local MenuItems = {}
  local current_item = nil

  for i = #M.buffers, 1, -1 do
    local buf = M.buffers[i]
    if bufvalid(buf) then
      local name = vim.api.nvim_buf_get_name(buf)
      if name == "" then name = "[No Name]" end
      table.insert(MenuItems, Menu.item(name, {buf = buf }))
    end
  end

  local menu = Menu(menu_opts, {
    lines =  MenuItems ,
    keymap = keymap,
    on_change = function (item )
      current_item = item
    end,
    on_submit = function(item)
      if not item then return end
      vim.api.nvim_set_current_buf(item.buf)
    end,
  })

  local update = function ()
    M.cycling = true
    menu:unmount()
    M.buffers_list()
    M.cycling = false
  end

  local remove_from_list = function ()
    if not current_item then return end
    remove( M.buffers , current_item.buf )
    update()
  end

  local clear = function ()
    if #M.buffers == 0 then return end
    M.clear_tracked_buffers()
    update()
  end

  local close_buf = function ()
    if not current_item then return end
    vim.cmd( 'bdelete ' .. current_item.buf)
    update()
  end

  local move_to_top = function ()
    if not current_item then return end
    remove( M.buffers, current_item.buf )
    table.insert( M.buffers, current_item.buf )
    update()
  end

  menu:map( 'n', 'd', remove_from_list )
  menu:map( 'n', 'D', clear )
  menu:map( 'n', 'x', close_buf )
  menu:map( 'n', 't', move_to_top )

  menu:mount()
end

function M.closed_buffers_list ()
  local Menu = require("nui.menu")
  local current_item = nil

  local MenuItems = {}
  for i = #M.closed_buffers, 1, -1 do
    local buf = M.closed_buffers[i]
    table.insert(MenuItems, Menu.item(buf))
  end

  local menu = Menu(vim.tbl_deep_extend(
    'force',
    menu_opts,
    { border = { text = { top = " Recently closed buffers " } } }
  ), {
    lines = MenuItems,
    keymap = keymap,
    on_change = function (item)
      current_item = item
    end,
    on_submit = function(item)
      if not item then return end
      vim.cmd('edit ' .. item.text)
      remove(M.closed_buffers , item.text)
    end,
  })

  local update = function ()
    M.cycling = true
    menu:unmount()
    M.closed_buffers_list()
    M.cycling = false
  end

  local remove_from_list = function ()
    if not current_item then return end
    remove( M.closed_buffers , current_item.text )
    update()
  end

  local clear = function ()
    if #M.closed_buffers == 0 then return end
    M.closed_buffers ={}
    update()
  end

  local move_to_top = function ()
    if not current_item then return end
    remove( M.closed_buffers, current_item.text )
    table.insert( M.closed_buffers, current_item.text )
    update()
  end

  menu:map( 'n', 'd', remove_from_list )
  menu:map( 'n', 'D', clear )
  menu:map( 'n', 't', move_to_top )

  menu:mount()
end

function M.clear_tracked_buffers()
  M.buffers = {}
  M.index = 1
  print("[buftrack.nvim] Cleared tracked buffers.")
end

function M.setup(opts)
  opts = opts or {}
  M.max_tracked = opts["max_tracked"] or 16

  vim.api.nvim_create_autocmd({ "BufEnter", "BufLeave" }, {
    callback = M.track_buffer
  })

  vim.api.nvim_create_autocmd({ "BufDelete", "BufWipeout" }, {
    callback = on_buffer_close
  })

  vim.api.nvim_create_user_command("BufReopen", M.reopen_buffer, {})
  vim.api.nvim_create_user_command("BufTrack", M.track_buffer, {})
  vim.api.nvim_create_user_command("BufTrackPrev", M.prev_buffer, {})
  vim.api.nvim_create_user_command("BufTrackNext", M.next_buffer, {})
  vim.api.nvim_create_user_command("BufTrackList", M.buffers_list, {})
  vim.api.nvim_create_user_command("BufClosedList", M.closed_buffers_list, {})
  vim.api.nvim_create_user_command("BufTrackClear", M.clear_tracked_buffers, {})
end

return M
