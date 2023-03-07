# nerdicons.nvim
get the nerdfont icons inside neovim . no need open nerdfont website to search icons anymore.

## Install

- lazy.nvim

```lua
require('lazy').setup({
 {'glepnir/nerdicons.nvim', config = function() require('nerdicons').setup() end}
})
```

- packer

```lua
use({'glepnir/nerdicons.nvim', config = function() require('nerdicons').setup() end})
```

## Usage

call the command `NerdIcons` with a argument, like `NerdIcons linux`

## License MIT
