local api = vim.api
local get_icons = require('nerdicons.icons').get_icons
local M = {}

function M.setup()
  api.nvim_create_user_command('NerdIcons', function(args)
    local icons = get_icons()
    local res = {}
    for _, v in pairs(icons) do
      if v.name:find(args.args) then
        res[#res + 1] = v.icon .. ' '
      end
    end
    print(vim.inspect(res))
  end, {
    nargs = '+',
  })
end

return M
