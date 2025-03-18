local M = {}

M.buffers = {}
M.index = 1
M.cycling = false
M.max_tracked = nil
M.closed_buffers =  {}

function M.track_buffer()
  if M.cycling then return end
  local buf = vim.api.nvim_get_current_buf()

  -- Remove existing entry if present
  for i, b in ipairs(M.buffers) do
    if b == buf then
      table.remove(M.buffers, i)
      break
    end
  end

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
  if (bufvalid (buf)) then
    local buf_name = vim.api.nvim_buf_get_name(buf)

    -- Remove existing entry if present
    for i, closed_buf in ipairs(M.closed_buffers) do
      if closed_buf == buf_name then
        table.remove(M.closed_buffers, i)
        table.insert(M.closed_buffers, buf_name)
        return
      end
    end
    table.insert(M.closed_buffers, buf_name)

    -- Cap buffer list size
    if #M.closed_buffers > M.max_tracked then
      table.remove(M.closed_buffers, 1)
    end
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

function M.print_tracked_buffers()
  if #M.buffers == 0 then
    print("[buftrack.nvim] No tracked buffers.")
    return
  end

  print("[buftrack.nvim] Tracked Buffers:")
  for i, buf in ipairs(M.buffers) do
    if vim.api.nvim_buf_is_valid(buf) then
      local name = vim.api.nvim_buf_get_name(buf)
      if name == "" then name = "[No Name]" end
      print(i .. ": " .. name)
    end
  end
  print("[buftrack.nvim] Cursor: ", M.index)
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

  vim.api.nvim_create_user_command("BufRepoen", M.reopen_buffer, {})
  vim.api.nvim_create_user_command("BufTrack", M.track_buffer, {})
  vim.api.nvim_create_user_command("BufTrackPrev", M.prev_buffer, {})
  vim.api.nvim_create_user_command("BufTrackNext", M.next_buffer, {})
  vim.api.nvim_create_user_command("BufTrackList", M.print_tracked_buffers, {})
  vim.api.nvim_create_user_command("BufTrackClear", M.clear_tracked_buffers, {})
end

return M
