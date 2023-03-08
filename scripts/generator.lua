--source file is view-source:https://www.nerdfonts.com/cheat-sheet
local fname = '/Users/joyce/Workspace/nerdicons.nvim/source.html'

local handle = io.open(fname, 'r')
if not handle then
  return
end

local content = {}

for line in handle:lines() do
  table.insert(content, line)
end

handle:close()

local res = {}
local remove = false

for _, v in pairs(content) do
  if v:find('obsolete') then
    remove = true
  end
  local codepoint = v:match('codepoint">(.+)</div>')
  if codepoint then
    local name = v:match('name">(.+)</div><div')
    name = name:sub(4)
    if not remove then
      res[#res + 1] = { codepoint = codepoint, name = name }
    else
      remove = false
    end
  end
end

print('local icons = {')

local count = 0

for _, v in pairs(res) do
  local tmp = v.codepoint
  if tmp:byte() > 101 then
    tmp = tmp:sub(1, 4)
  end
  local output = io.popen([[zsh -c "echo \\\\u"]] .. tmp)
  if output then
    local icon = output:read('*a')
    icon = icon:gsub('\n', '')
    print(
      "\t['"
        .. v.codepoint
        .. "'] = "
        .. " { name = '"
        .. v.name
        .. "',"
        .. "icon = '"
        .. icon
        .. "'},"
    )
    output:close()
    count = count + 1
  end
end

print('}')
print('Total icons: ' .. count)
print('--------------end----------------')
