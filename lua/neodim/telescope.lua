local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local sorters = require("telescope.sorters")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local get_snapshots = require("neodim.management").get_snapshots
local open_layout = require("neodim.management").open_layout
local delete_layout = require("neodim.management").delete_layout
local rename_layout = require("neodim.management").rename_layout

local function snapshots_picker()
  pickers
    .new(require("telescope.themes").get_dropdown({}), {
      layout_config = {
        width = 0.5,
        height = 0.2,
      },
      initial_mode = "normal",
      prompt_title = "Select a Snapshot",
      finder = finders.new_table({
        results = get_snapshots(),
        entry_maker = function(entry)
          return {
            value = entry,
            display = entry.name,
            ordinal = entry.name,
            name = entry.name,
          }
        end,
      }),
      sorter = sorters.get_generic_fuzzy_sorter(),
      attach_mappings = function(_, map)
        local function enter_handler(prompt_bufnr)
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          if selection then
            print(selection.name)
            open_layout(selection.name)
          end
        end

        local function delete_handler(prompt_bufnr)
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          if selection then
            delete_layout(selection.name)
          end
          snapshots_picker()
        end

        local function rename_handler(prompt_bufnr)
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          if selection then
            rename_layout(selection.name)
          end
          snapshots_picker()
        end

        map("i", "<CR>", enter_handler)
        map("n", "<CR>", enter_handler)
        map("n", "dd", delete_handler)
        map("n", "r", rename_handler)
        return true
      end,
    })
    :find()
end

return {
  snapshots_picker = snapshots_picker,
}