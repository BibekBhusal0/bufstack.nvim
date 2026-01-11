local M = {}
M.bufvalid = function(bufnr)
	return vim.api.nvim_buf_is_loaded(bufnr)
		and vim.api.nvim_buf_is_valid(bufnr)
		and vim.bo[bufnr].buflisted
		and vim.bo[bufnr].buftype == ""
end

M.remove = function(tb, item, remove_all)
	for i, b in ipairs(tb) do
		if b == item then
			table.remove(tb, i)
			if not remove_all then
				break
			end
		end
	end
end

M.move_to_top = function(tb, item, remove_all)
	M.remove(tb, item, remove_all)
	table.insert(tb, item)
end

M.cap_list_size = function(list, max_size)
	max_size = max_size or require("bufstack.core").opts.max_tracked
	while #list > max_size do
		table.remove(list, 1)
	end
end

M.shorten_path = function(path)
	return require("plenary.path"):new(path):shorten(1)
end

return M
