local paths = require("skill-issue.paths")

local M = {}

-- Pulls just the "name:" and "description:" fields out of a SKILL.md's
-- frontmatter -- not a full YAML parser, that's more than this needs.
local function parse_frontmatter(path)
  local f = io.open(path, "r")
  if not f then
    return nil, nil
  end

  local name, description
  local in_frontmatter = false
  for line in f:lines() do
    if line == "---" then
      if in_frontmatter then
        break
      end
      in_frontmatter = true
    elseif in_frontmatter then
      local key, value = line:match("^(%w+):%s*(.*)$")
      if key == "name" then
        name = value
      elseif key == "description" then
        description = value
      end
    end
  end
  f:close()
  return name, description
end

local function scan(dir, level)
  local result = {}
  if dir == nil or vim.fn.isdirectory(dir) == 0 then
    return result
  end
  for entry, entry_type in vim.fs.dir(dir) do
    if entry_type == "directory" then
      local skill_dir = vim.fs.joinpath(dir, entry)
      local skill_md = vim.fs.joinpath(skill_dir, "SKILL.md")
      if vim.fn.filereadable(skill_md) == 1 then
        local name, description = parse_frontmatter(skill_md)
        table.insert(result, {
          name = name or entry,
          dir_name = entry,
          description = description or "",
          level = level,
          path = skill_dir,
          skill_md = skill_md,
        })
      end
    end
  end
  return result
end

function M.list()
  local items = {}
  vim.list_extend(items, scan(paths.project_dir(), "project"))
  vim.list_extend(items, scan(paths.global_dir(), "global"))
  table.sort(items, function(a, b)
    return a.name < b.name
  end)
  return items
end

function M.exists(level, dir_name)
  local dir = level == "global" and paths.global_dir() or paths.project_dir()
  if dir == nil then
    return false
  end
  return vim.fn.isdirectory(vim.fs.joinpath(dir, dir_name)) == 1
end

return M
