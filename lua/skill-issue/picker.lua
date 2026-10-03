local skills = require("skill-issue.skills")
local actions = require("skill-issue.actions")
local paths = require("skill-issue.paths")

local M = {}

local state = { buf = nil, win = nil, items = nil }

local function format_item(item)
  return string.format("[%s] %-20s %s", item.level, item.name, item.description)
end

local function render()
  if not (state.buf and vim.api.nvim_buf_is_valid(state.buf)) then
    return
  end

  state.items = skills.list()
  local lines = {}
  if #state.items == 0 then
    lines = { "(no skills yet -- press 'a' to create one)" }
  else
    for _, item in ipairs(state.items) do
      table.insert(lines, format_item(item))
    end
  end

  vim.bo[state.buf].modifiable = true
  vim.api.nvim_buf_set_lines(state.buf, 0, -1, false, lines)
  vim.bo[state.buf].modifiable = false
end

local function current_item()
  if not state.items or #state.items == 0 then
    return nil
  end
  local line = vim.api.nvim_win_get_cursor(state.win)[1]
  return state.items[line]
end

local function close()
  if state.win and vim.api.nvim_win_is_valid(state.win) then
    vim.api.nvim_win_close(state.win, true)
  end
  state.win, state.buf, state.items = nil, nil, nil
end

local function do_create(level)
  vim.ui.input({ prompt = "Skill name: " }, function(name)
    if not name or name == "" then
      return
    end
    vim.ui.input({ prompt = "Description: " }, function(description)
      actions.create(level, name, description or "")
      close()
    end)
  end)
end

local function prompt_create()
  if paths.project_dir() ~= nil then
    vim.ui.select({ "project", "global" }, { prompt = "Create skill where?" }, function(choice)
      if choice then
        do_create(choice)
      end
    end)
  else
    do_create("global")
  end
end

local function set_keymaps(buf)
  local opts = { buffer = buf, nowait = true, silent = true }

  vim.keymap.set("n", "<CR>", function()
    local item = current_item()
    if item then
      close()
      actions.edit(item)
    end
  end, opts)

  vim.keymap.set("n", "a", prompt_create, opts)

  vim.keymap.set("n", "d", function()
    local item = current_item()
    if item then
      actions.delete(item, render)
    end
  end, opts)

  vim.keymap.set("n", "q", close, opts)
  vim.keymap.set("n", "<Esc>", close, opts)
end

function M.open()
  if state.win and vim.api.nvim_win_is_valid(state.win) then
    vim.api.nvim_set_current_win(state.win)
    return
  end

  state.buf = vim.api.nvim_create_buf(false, true)
  vim.bo[state.buf].bufhidden = "wipe"
  vim.bo[state.buf].filetype = "skill-issue"

  local width = math.floor(vim.o.columns * 0.6)
  local height = math.floor(vim.o.lines * 0.5)
  state.win = vim.api.nvim_open_win(state.buf, true, {
    relative = "editor",
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    width = width,
    height = height,
    style = "minimal",
    border = "rounded",
    title = " Skills  [a]dd  [d]elete  <CR> edit  [q]uit ",
    title_pos = "center",
  })

  render()
  set_keymaps(state.buf)
end

return M
