local core = require("buftrack.core")
local ui = require("buftrack.ui")

local M = {}

M.setup = function(opts)
	opts = opts or {}
	core.max_tracked = opts["max_tracked"] or 16

	vim.api.nvim_create_autocmd({ "BufEnter", "BufLeave" }, {
		callback = core.track_buffer,
	})

	vim.api.nvim_create_autocmd({ "BufDelete", "BufWipeout" }, {
		callback = core.on_buffer_close,
	})

	vim.api.nvim_create_user_command("BufReopen", core.reopen_buffer, {})
	vim.api.nvim_create_user_command("BufTrack", core.track_buffer, {})
	vim.api.nvim_create_user_command("BufTrackPrev", core.prev_buffer, {})
	vim.api.nvim_create_user_command("BufTrackNext", core.next_buffer, {})
	vim.api.nvim_create_user_command("BufTrackList", ui.buffers_list, {})
	vim.api.nvim_create_user_command("BufClosedList", ui.closed_buffers_list, {})
	vim.api.nvim_create_user_command("BufTrackClear", core.clear_tracked_buffers, {})
end

return M
