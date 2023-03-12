local api = vim.api
local nvim_buf_set_keymap = api.nvim_buf_set_keymap
local M = {}

local function get_indent()
  return (' '):rep(api.nvim_strwidth(M.opt.preview_prompt))
end

local function clean_icons()
  M.icons = nil
end

local function render_result(text, preview_bufnr, height)
  if not M.icons then
    M.icons = require('nerdicons.icons').get_icons()
  end
  local res = {}
  local indent = get_indent()

  local function insert_res(name, icon, index)
    res[#res + 1] = (index == 1 and M.opt.preview_prompt or indent)
      .. 'Icon: '
      .. icon
      .. '  Name: '
      .. name
  end

  local index = 1
  for k, v in pairs(M.icons) do
    if height and index > height and not text then
      break
    end

    if text and k:find(text) then
      insert_res(k, v, index)
      index = index + 1
    elseif not text then
      insert_res(k, v, index)
      index = index + 1
    end
  end

  api.nvim_buf_set_lines(preview_bufnr, 0, -1, false, res)

  api.nvim_buf_add_highlight(preview_bufnr, 0, 'NerdIconSelectPrompt', 0, 0, #M.opt.preview_prompt)
end

local function preview_window(prompt_float_opt, argument)
  prompt_float_opt.row = prompt_float_opt.row + 3
  prompt_float_opt.height = 10
  local preview_bufnr = api.nvim_create_buf(false, false)
  local preview_winid = api.nvim_open_win(preview_bufnr, false, prompt_float_opt)
  api.nvim_set_option_value('winhl', 'Normal:NerdIconNormal,FloatBorder:NerdIconBorder', {
    scope = 'local',
    win = preview_winid,
  })
  vim.bo[preview_bufnr].bufhidden = 'wipe'
  api.nvim_set_option_value('wrap', false, { scope = 'local', win = preview_winid })
  render_result(argument, preview_bufnr, prompt_float_opt.height)
  return preview_bufnr, preview_winid
end

local function prompt_window(opt, argument)
  local float_opt = {
    relative = 'editor',
    border = opt.border,
    style = 'minimal',
  }
  float_opt.height = 1
  float_opt.width = math.floor(vim.o.columns * opt.width)
  float_opt.row = math.floor(vim.o.lines * 0.2)
  float_opt.col = math.floor(vim.o.columns / 2 - float_opt.width / 2)
  local bufnr = api.nvim_create_buf(false, false)

  vim.bo[bufnr].buftype = 'prompt'
  vim.bo[bufnr].bufhidden = 'wipe'
  local winid = api.nvim_open_win(bufnr, true, float_opt)
  local function reset_prompt_hi()
    vim.defer_fn(function()
      api.nvim_win_call(winid, function()
        local current_row = api.nvim_win_get_cursor(winid)[1] - 1
        api.nvim_buf_add_highlight(bufnr, 0, 'NerdIconPrompt', current_row, 0, #M.opt.prompt)
      end)
    end, 0)
  end

  api.nvim_set_option_value('winhl', 'Normal:NerdIconNormal,FloatBorder:NerdIconBorder', {
    scope = 'local',
    win = winid,
  })
  vim.fn.prompt_setprompt(bufnr, ' ' .. opt.prompt)
  reset_prompt_hi()

  vim.cmd('startinsert')

  local preview_bufnr, preview_winid = preview_window(float_opt, argument)
  vim.fn.prompt_setcallback(bufnr, function(text)
    if not text or #text == 0 then
      reset_prompt_hi()
    else
      render_result(text, preview_bufnr, nil)
    end
    reset_prompt_hi()
  end)

  local function cursor_move(direct)
    if preview_winid and api.nvim_win_is_valid(preview_winid) then
      api.nvim_win_call(preview_winid, function()
        local current_row = api.nvim_win_get_cursor(preview_winid)[1]
        local new_row = current_row + direct
        local total_lines = api.nvim_buf_line_count(preview_bufnr)
        if new_row > total_lines then
          new_row = 1
        elseif new_row < 1 then
          new_row = total_lines
        end
        api.nvim_win_set_cursor(preview_winid, { new_row, 1 })
        local curline = api.nvim_get_current_line()
        local icon_len = #M.opt.preview_prompt - 1
        curline = curline:sub(icon_len)
        curline = M.opt.preview_prompt .. curline
        api.nvim_buf_set_lines(preview_bufnr, new_row - 1, new_row, false, { curline })
        local prev_line =
          api.nvim_buf_get_lines(preview_bufnr, current_row - 1, current_row, false)[1]
        prev_line = (' '):rep(api.nvim_strwidth(M.opt.preview_prompt) - 1)
          .. prev_line:sub(#M.opt.preview_prompt)
        api.nvim_buf_set_lines(preview_bufnr, current_row - 1, current_row, false, { prev_line })
        api.nvim_buf_add_highlight(
          preview_bufnr,
          0,
          'NerdIconSelectPrompt',
          new_row - 1,
          0,
          #M.opt.preview_prompt
        )
      end)
    end
  end

  nvim_buf_set_keymap(bufnr, 'i', M.opt.down, '<NOP>', {
    noremap = true,
    nowait = true,
    callback = function()
      cursor_move(1)
    end,
  })

  nvim_buf_set_keymap(bufnr, 'i', M.opt.up, '', {
    noremap = true,
    nowait = true,
    callback = function()
      cursor_move(-1)
    end,
  })

  nvim_buf_set_keymap(bufnr, 'i', M.opt.copy, '', {
    noremap = true,
    nowait = true,
    callback = function()
      vim.cmd('stopinsert')
      if preview_bufnr and api.nvim_buf_is_valid(preview_bufnr) then
        api.nvim_buf_call(preview_bufnr, function()
          local text = api.nvim_get_current_line()
          local icon = text:match('Icon:%s(.+)%sN')
          vim.fn.setreg('@0', icon)
          api.nvim_win_close(preview_winid, true)
          api.nvim_win_close(winid, true)
        end)
      end
      clean_icons()
    end,
  })

  nvim_buf_set_keymap(bufnr, 'n', '<Esc>', '', {
    noremap = true,
    nowait = true,
    callback = function()
      pcall(api.nvim_win_close, preview_winid, true)
      pcall(api.nvim_win_close, winid, true)
      clean_icons()
    end,
  })
end

local function default_opts()
  return {
    border = 'single',
    width = 0.5,
    prompt = '󰨭 ',
    preview_prompt = ' ',
    down = '<C-n>',
    up = '<C-p>',
    copy = '<C-y>',
  }
end

function M.instance(argument)
  prompt_window(M.opt, argument)
end

function M.setup(opt)
  M.opt = vim.tbl_extend('force', default_opts(), opt)
end

return M
