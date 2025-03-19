local utils = require("buftrack.utils")

local M = {}
M.buffers = {}
M.index = 1
M.cycling = false
M.max_tracked = 16
M.closed_buffers = {}

function M.track_buffer()
	if M.cycling then
		return
	end
	local buf = vim.api.nvim_get_current_buf()
	if not utils.bufvalid(buf) then
		return
	end

	utils.remove(M.buffers, buf)

	table.insert(M.buffers, buf)
	utils.cap_list_size(M.buffers, M.max_tracked)
	M.index = #M.buffers
end

function M.clear_tracked_buffers()
	M.buffers = {}
	M.index = 1
	print("Cleared tracked buffers.")
end

function M.clear_closed()
	M.closed_buffers = {}
	print("Cleared tracked closed buffers.")
end

function M.clear()
	M.clear_tracked_buffers()
	M.clear_closed()
end

local function get_valid_buffer(start_index, direction)
	local count = #M.buffers
	local index = start_index
	while index >= 1 and index <= count do
		if utils.bufvalid(M.buffers[index]) then
			return index
		else
			table.remove(M.buffers, index)
			count = math.max(0, M.index - 1)
			M.index = math.max(1, M.index - 1)
			if count == 0 then
				return nil
			end
		end
		index = index + direction
	end
	return nil
end

function M.next_buffer()
	if #M.buffers == 0 then
		return
	end
	M.cycling = true
	local new_index = get_valid_buffer(M.index + 1, 1)
	if new_index then
		M.index = new_index
		vim.api.nvim_set_current_buf(M.buffers[M.index])
	else
		print("Reached the latest buffer.")
	end
	M.cycling = false
end

function M.prev_buffer()
	if #M.buffers == 0 then
		return
	end
	M.cycling = true
	local new_index = get_valid_buffer(M.index - 1, -1)
	if new_index then
		M.index = new_index
		vim.api.nvim_set_current_buf(M.buffers[M.index])
	else
		print("Reached the oldest buffer.")
	end
	M.cycling = false
end

function M.reopen_buffer()
	if #M.closed_buffers > 0 then
		local last_closed_buf = table.remove(M.closed_buffers)
		vim.cmd("edit " .. last_closed_buf)
	else
		print("No closed buffers to reopen.")
	end
end

return M
