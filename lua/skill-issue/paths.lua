local M = {}

function M.global_dir()
  return vim.fs.joinpath(vim.fn.expand("~"), ".claude", "skills")
end

-- nil outside a git repo: there is no sensible project-level location there.
function M.project_dir()
  local root = vim.fs.root(0, ".git")
  if not root then
    return nil
  end
  return vim.fs.joinpath(root, ".claude", "skills")
end

return M
