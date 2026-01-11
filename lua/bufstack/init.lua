local core = require("bufstack.core")
local ui = require("bufstack.ui")
local utils = require("bufstack.utils")

local M = {}

local on_buffer_close = function(args)
	local buf = args.buf
	if not (utils.bufvalid(buf)) then
		return
	end
	local buf_name = vim.api.nvim_buf_get_name(buf)

	utils.move_to_top(core.closed_buffers, buf_name)
	utils.cap_list_size(core.closed_buffers)
end

M.setup = function(opts)
	core.opts = vim.tbl_deep_extend("force", core.opts, opts)

	vim.api.nvim_create_autocmd({ "BufEnter", "BufLeave" }, {
		callback = core.track_buffer,
	})

	vim.api.nvim_create_autocmd({ "BufDelete", "BufWipeout" }, {
		callback = on_buffer_close,
	})

	vim.api.nvim_create_user_command("BufReopen", core.reopen_buffer, {})
	vim.api.nvim_create_user_command("BufStack", core.track_buffer, {})
	vim.api.nvim_create_user_command("BufStackPrev", core.prev_buffer, {})
	vim.api.nvim_create_user_command("BufStackNext", core.next_buffer, {})
	vim.api.nvim_create_user_command("BufStackList", ui.buffers_list, {})
	vim.api.nvim_create_user_command("BufClosedList", ui.closed_buffers_list, {})
	vim.api.nvim_create_user_command("BufStackClear", core.clear_tracked_buffers, {})
	vim.api.nvim_create_user_command("BufClear", core.clear, {})
	vim.api.nvim_create_user_command("BufClosedClear", core.clear_closed, {})
end

return M
