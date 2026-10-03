# Glossary

**Build** — the action of scaffolding a brand-new Skill: creating its directory and a `SKILL.md` with boilerplate frontmatter, ready for the user to fill in.

**Global Skill** — a Skill stored in `~/.claude/skills/`, available to every project on the machine.

**Project Skill** — a Skill stored in `<git-root>/.claude/skills/`, available only within that repo.

**Skill** — a Claude Code Agent Skill: a directory containing a `SKILL.md` file (YAML frontmatter with `name` and `description`, plus a body of instructions) and optional supporting files (scripts, references). This plugin manages Skills in this exact format so they work identically whether created via this plugin or by hand.
