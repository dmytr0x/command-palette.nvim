local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local actions = require("telescope.actions")
local actions_state = require("telescope.actions.state")
local config = require("telescope.config").values

local M = {}

function M.command(title, command, ordinal)
  local cmd = {
    title = title,
    command = command,
  }

  if ordinal == nil then
    cmd["ordinal"] = title
  else
    cmd["ordinal"] = title .. ":" .. ordinal
  end

  return cmd
end

function M.command_palette(opts)
  local data = {}
  for item in vim.iter(M.sources):flatten() do
    table.insert(data, item)
  end

  pickers
    .new(opts, {
      prompt_title = "Command Palette",
      finder = finders.new_table({
        results = data,
        entry_maker = function(entity)
          return {
            value = entity,
            display = entity.title,
            ordinal = entity.ordinal,
          }
        end,
      }),
      sorter = config.generic_sorter(opts),
      attach_mappings = function(prompt_bufnr)
        actions.select_default:replace(function()
          local selection = actions_state.get_selected_entry()
          actions.close(prompt_bufnr)

          -- run user function
          selection.value.command()
        end)
        return true
      end,
    })
    :find()
end

function M.setup(sources)
  M.sources = sources
end

return M
