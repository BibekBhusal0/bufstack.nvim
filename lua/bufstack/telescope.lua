local core = require("bufstack.core")
local utils = require("bufstack.utils")

local function reopen()
	require("telescope.pickers")
		.new({}, {
			finder = require("telescope.finders").new_table({
				results = core.closed_buffers,
			}),
			sorter = require("telescope.config").values.generic_sorter({}),

			attach_mappings = function(prompt_bufnr)
				local actions = require("telescope.actions")
				local run_action = function(callback)
					return function()
						local selection = require("telescope.actions.state").get_selected_entry()
						actions.close(prompt_bufnr)
						callback(selection.value)
					end
				end
				actions.select_default:replace(run_action(core.reopen_buffer_w_name))

				return true
			end,
		})
		:find()
end

return { reopen = reopen }
