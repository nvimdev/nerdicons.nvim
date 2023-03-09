local api = vim.api
local nvim_set_hl = api.nvim_set_hl

if vim.fn.exists('g:loaded_nerdicons') == 1 then
  return
end

vim.g.loaded_nerdicons = 1

api.nvim_create_user_command('NerdIcons', function(args)
  local argument
  if #args.args > 0 then
    argument = args.args
  end
  require('nerdicons').instance(argument)
end, {
  nargs = '?',
})

nvim_set_hl(0, 'NerdIconPrompt', {
  link = 'String',
  default = true,
})

nvim_set_hl(0, 'NerdIconSelectPrompt', {
  link = 'Constant',
  default = true,
})

nvim_set_hl(0, 'NerdIconBorder', {
  link = '@variable',
  default = true,
})
