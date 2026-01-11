local core = require("bufstack.core")
local M = {}

M.on_save = function()
	return { buffers = core.buffers, closed_buffers = core.closed_buffers }
end

M.on_load = function(data)
	if not data then
		return
	end
	if data.buffers then
		core.buffers = data.buffers
	end
	if data.closed_buffers then
		core.closed_buffers = data.closed_buffers
	end
end

return M
