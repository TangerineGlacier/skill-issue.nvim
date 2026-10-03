if vim.g.loaded_skill_issue then
  return
end
vim.g.loaded_skill_issue = true

vim.api.nvim_create_user_command("SkillIssue", function()
  require("skill-issue").open()
end, { desc = "Open the Skill Issue picker" })
