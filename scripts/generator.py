# Read icon form glyphnames.json file
# Then generate the icons.lua file
import json

min = 62721
max = 65535

lua_str = 'local function get_icons()\n  local icons = {\n'
indent = '    '

target = open('./lua/nerdicons/icons.lua','w')
target.write(lua_str)

with open('./scripts/glyphnames.json') as f:
    data = json.load(f)
    for i in data:
        if i != 'METADATA':
            code = int(str(data[i]['code']), 16)
            if code < min or code > max:
                char =  str(data[i]['char'])
                target.write(indent + '["'+i+'"] = "'+ char + '",\n')

target.write('  }\n return icons\nend\nreturn {\n  get_icons = get_icons,\n}')
target.close()
