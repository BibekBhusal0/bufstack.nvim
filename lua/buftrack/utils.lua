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

return {
	bufvalid = bufvalid,
	remove = remove,
}
