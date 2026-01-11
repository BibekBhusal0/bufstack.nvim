local core = require("bufstack.core")
local utils = require("bufstack.utils")

local function reopen()
	local fullNameMapping = {}
	local function createFinder()
		fullNameMapping = {}
		local bufNames = {}
		for i = #core.closed_buffers, 1, -1 do
			local fullName = core.closed_buffers[i]
			local buf = fullName
			if core.opts.shorten_path then
				buf = utils.shorten_path(buf)
			end
			table.insert(bufNames, buf)
			fullNameMapping[buf] = fullName
		end
		return require("telescope.finders").new_table({
			results = bufNames,
		})
	end
	require("telescope.pickers")
		.new(
			{},
			vim.tbl_deep_extend("force", core.opts.telescope_config, {
				prompt_title = "Reopen Buffer",
				finder = createFinder(),
				sorter = require("telescope.config").values.generic_sorter({}),

				attach_mappings = function(prompt_bufnr, map)
					local actions = require("telescope.actions")
					local run_action = function(callback, action)
						return function()
							local action_state = require("telescope.actions.state")
							local current_picker = action_state.get_current_picker(prompt_bufnr)
							local selections = current_picker:get_multi_selection()

							if vim.tbl_isempty(selections) then
								local selection = action_state.get_selected_entry()
								if selection ~= nil then
									table.insert(selections, selection)
								end
							end

							if action == "refresh" then
								for _, selection in ipairs(selections) do
									if selection ~= nil then
										callback(fullNameMapping[selection.value])
									end
								end
								current_picker:refresh(createFinder())
							else
								actions.close(prompt_bufnr)
								for _, selection in ipairs(selections) do
									if selection ~= nil then
										callback(fullNameMapping[selection.value])
									end
								end
							end
						end
					end
					actions.select_default:replace(run_action(core.reopen_buffer_w_name))

					map({ "n" }, "d", run_action(core.remove_from_closed_list, "refresh"))
					map({ "n" }, "t", run_action(core.move_closed_buf_to_top, "refresh"))
					map({ "n" }, "D", run_action(core.clear_closed, "refresh"))
					return true
				end,
			})
		)
		:find()
end

return { reopen = reopen }
