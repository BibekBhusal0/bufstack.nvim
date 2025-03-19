local core = require("bufstack.core")
local utils = require("bufstack.utils")
local M = {}

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

function M.buffers_list()
	local Menu = require("nui.menu")
	local MenuItems = {}
	local current_item = nil

	for i = #core.buffers, 1, -1 do
		local buf = core.buffers[i]
		if utils.bufvalid(buf) then
			local name = vim.api.nvim_buf_get_name(buf)
			if name == "" then
				name = "[No Name]"
			end
			table.insert(MenuItems, Menu.item(name, { buf = buf }))
		end
	end

	local menu = Menu(menu_opts, {
		lines = MenuItems,
		keymap = keymap,
		on_change = function(item)
			current_item = item
		end,
		on_submit = function(item)
			if not item then
				return
			end
			vim.api.nvim_set_current_buf(item.buf)
		end,
	})

	local update = function()
		core.cycling = true
		menu:unmount()
		M.buffers_list()
		core.cycling = false
	end

	local remove_from_list = function()
		if not current_item then
			return
		end
		utils.remove(core.buffers, current_item.buf)
		update()
	end

	local clear = function()
		if #core.buffers == 0 then
			return
		end
		core.clear_tracked_buffers()
		menu:unmount()
	end

	local close_buf = function()
		if not current_item then
			return
		end
		vim.cmd("bdelete " .. current_item.buf)
		update()
	end

	local move_to_top = function()
		if not current_item then
			return
		end
		utils.remove(core.buffers, current_item.buf)
		table.insert(core.buffers, current_item.buf)
		update()
	end

	menu:map("n", "d", remove_from_list)
	menu:map("n", "D", clear)
	menu:map("n", "x", close_buf)
	menu:map("n", "t", move_to_top)

	menu:mount()
end

function M.closed_buffers_list()
	local Menu = require("nui.menu")
	local current_item = nil

	local MenuItems = {}
	for i = #core.closed_buffers, 1, -1 do
		local buf = core.closed_buffers[i]
		table.insert(MenuItems, Menu.item(buf))
	end

	local menu =
		Menu(vim.tbl_deep_extend("force", menu_opts, { border = { text = { top = " Recently closed buffers " } } }), {
			lines = MenuItems,
			keymap = keymap,
			on_change = function(item)
				current_item = item
			end,
			on_submit = function(item)
				if not item then
					return
				end
				vim.cmd("edit " .. item.text)
				utils.remove(core.closed_buffers, item.text)
			end,
		})

	local update = function()
		core.cycling = true
		menu:unmount()
		M.closed_buffers_list()
		core.cycling = false
	end

	local remove_from_list = function()
		if not current_item then
			return
		end
		utils.remove(core.closed_buffers, current_item.text)
		update()
	end

	local clear = function()
		if #core.closed_buffers == 0 then
			return
		end
		core.clear_closed()
		menu:unmount()
	end

	local move_to_top = function()
		if not current_item then
			return
		end
		utils.remove(core.closed_buffers, current_item.text)
		table.insert(core.closed_buffers, current_item.text)
		update()
	end

	menu:map("n", "d", remove_from_list)
	menu:map("n", "D", clear)
	menu:map("n", "t", move_to_top)

	menu:mount()
end

return M
