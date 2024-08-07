local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local actions = require("telescope.actions")
local actions_state = require("telescope.actions.state")
local config = require("telescope.config").values

local log = require("plenary.log").new({
  plugin = "command_palette",
  level = "info",
})

local M = {}

function M.command(title, command, ordinal, init)
  local cmd = {
    title = title,
    command = command,
  }

  if ordinal == nil then
    cmd["ordinal"] = title
  else
    cmd["ordinal"] = title .. ":" .. ordinal
  end

  if init ~= nil then
    cmd["init"] = init
  end

  return cmd
end

function M.picker(opts)
  pickers
    .new(opts, {
      prompt_title = "Command Palette",
      finder = finders.new_table({
        results = M.commands,
        entry_maker = function(entity)
          return {
            display = entity.title,
            ordinal = entity.ordinal,
            entity = entity,
          }
        end,
      }),
      sorter = config.generic_sorter(opts),
      attach_mappings = function(prompt_bufnr)
        actions.select_default:replace(function()
          local selection = actions_state.get_selected_entry()
          actions.close(prompt_bufnr)

          -- run user function
          selection.entity.command()
        end)
        return true
      end,
    })
    :find()
end

function M.setup(sources)
  local commands = {}
  for item in vim.iter(sources) do
    if item["init"] ~= nil then
      log.debug('Run init function for "' .. item["title"] .. '"')

      -- run command's initialization function
      item["init"]()
    end
    table.insert(commands, item)
  end
  M.commands = commands
end

return M
