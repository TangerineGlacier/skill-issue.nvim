local paths = require("skill-issue.paths")
local skills = require("skill-issue.skills")

local M = {}

local TEMPLATE = [[---
name: %s
description: %s
---

# %s

]]

local function notify_error(msg)
  vim.notify("skill-issue: " .. msg, vim.log.levels.ERROR)
end

function M.create(level, name, description)
  if name == nil or name == "" then
    return
  end
  if name:match("[/\\]") then
    notify_error("skill name can't contain a path separator")
    return
  end

  local dir = level == "global" and paths.global_dir() or paths.project_dir()
  if dir == nil then
    notify_error("no project (.git) found here -- can't create a project skill")
    return
  end
  if skills.exists(level, name) then
    notify_error(("a %s skill named %q already exists"):format(level, name))
    return
  end

  local skill_dir = vim.fs.joinpath(dir, name)
  vim.fn.mkdir(skill_dir, "p")

  local skill_md = vim.fs.joinpath(skill_dir, "SKILL.md")
  local f = io.open(skill_md, "w")
  if not f then
    notify_error("failed to create " .. skill_md)
    return
  end
  f:write(TEMPLATE:format(name, description or "", name))
  f:close()

  vim.cmd.edit(skill_md)
end

function M.edit(skill)
  vim.cmd.edit(skill.skill_md)
end

function M.delete(skill, on_done)
  vim.ui.select({ "No", "Yes" }, {
    prompt = ("Delete %s skill %q? This removes the whole folder."):format(skill.level, skill.name),
  }, function(choice)
    if choice == "Yes" then
      vim.fn.delete(skill.path, "rf")
      vim.notify(("skill-issue: deleted %s"):format(skill.name))
      if on_done then
        on_done()
      end
    end
  end)
end

return M
