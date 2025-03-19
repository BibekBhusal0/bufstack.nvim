local bufvalid = require("buftrack.utils").bufvalid
local remove = require("buftrack.utils").remove

local M = {}
M.buffers = {}
M.index = 1
M.cycling = false
M.max_tracked = 16
M.closed_buffers = {}

M.on_buffer_close = function(args)
	local buf = args.buf
	if not (bufvalid(buf)) then
		return
	end
	local buf_name = vim.api.nvim_buf_get_name(buf)

	remove(M.closed_buffers, buf_name)
	table.insert(M.closed_buffers, buf_name)

	-- Cap buffer list size
	if #M.closed_buffers > M.max_tracked then
		table.remove(M.closed_buffers, 1)
	end
end

function M.track_buffer()
	if M.cycling then
		return
	end
	local buf = vim.api.nvim_get_current_buf()

	remove(M.buffers, buf)

	table.insert(M.buffers, buf)
	-- Cap buffer list size
	if #M.buffers > M.max_tracked then
		table.remove(M.buffers, 1)
	end

	M.index = #M.buffers
end

function M.clear_tracked_buffers()
	M.buffers = {}
	M.index = 1
	print("[buftrack.nvim] Cleared tracked buffers.")
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
		print("[buftrack.nvim] Reached the latest buffer.")
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
		print("[buftrack.nvim] Reached the oldest buffer.")
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
