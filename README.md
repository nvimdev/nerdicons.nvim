# nerdicons.nvim
get the nerdfont icons inside neovim . no need open nerdfont website to search icons anymore.

![nerdicons](https://user-images.githubusercontent.com/41671631/223701949-88c95719-8371-4572-8573-987e6c17c373.gif)

## Install

- lazy.nvim

```lua
require('lazy').setup({
 {'glepnir/nerdicons.nvim', cmd = 'NerdIcons', config = function() require('nerdicons').setup({}) end}
})
```

- packer

```lua
use({'glepnir/nerdicons.nvim', cmd = 'NerdIcons', config = function() require('nerdicons').setup({}) end})
```

## Options

available options in setup params table

```lua
{
    border = 'single',       -- Border
    prompt = '󰨭 ',           -- Prompt Icon
    preview_prompt = ' ',   -- Preview Prompt Icon
    width = 0.5              -- flaot window width
    down = '<C-n>',          -- Move down in preview
    up = '<C-p>',            -- Move up in preview
    copy = '<C-y>',          -- Copy to the clipboard
}
```

close the nerdicons window in prompt buffer you can exit to normal mode then press `<Esc>` or
`Ctrl-c`

## Usage

- call the command `NerdIcons` or with an argument like `NerdIcons linux`
- input the keyword of icon name
- `Ctrl n` or `Ctrl p` to move in preview
- `Ctrl y` to copy the icon

## Highlight

all the highlight groups

```
NerdIconPrompt NerdIconPreviewPrompt NerdIconNormal NerdIconBorder
```


## License MIT
