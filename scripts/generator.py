# Read icon form glyphnames.json file
# Then generate the icons.lua file
import json

lua_str = 'local function get_icons()\n  local icons = {\n'
indent = '    '

target = open('./lua/nerdicons/icons.lua','w')
target.write(lua_str)

with open('./scripts/glyphnames.json') as f:
    data = json.load(f)
    for i in data:
        if i != 'METADATA':
            code =  str(data[i])
            print('\u2665')
            target.write(indent + '["'+i+'"] = "'+ code + '",\n')

target.write('  }\n return icons\nend\nreturn {\n  get_icons = get_icons,\n}')
target.close()
