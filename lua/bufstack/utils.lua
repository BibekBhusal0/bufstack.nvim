local function bufvalid(bufnr)
	return vim.api.nvim_buf_is_loaded(bufnr)
		and vim.api.nvim_buf_is_valid(bufnr)
		and vim.bo[bufnr].buflisted
		and vim.bo[bufnr].buftype == ""
end

local remove = function(tb, item, remove_all)
	for i, b in ipairs(tb) do
		if b == item then
			table.remove(tb, i)
			if not remove_all then
				break
			end
		end
	end
end

local move_to_top = function(tb, item, remove_all)
	remove(tb, item, remove_all)
	table.insert(tb, item)
end

local function cap_list_size(list, max_size)
	max_size = max_size or require("bufstack.core").opts.max_tracked
	while #list > max_size do
		table.remove(list, 1)
	end
end

local function shorten(path)
	return require("plenary.path"):new(path):shorten(1)
end

return {
	bufvalid = bufvalid,
	remove = remove,
	cap_list_size = cap_list_size,
	shorten_path = shorten,
	move_to_top = move_to_top,
}
