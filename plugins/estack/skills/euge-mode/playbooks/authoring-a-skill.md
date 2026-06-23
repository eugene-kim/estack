### Authoring or modifying a skill

**You own the skill's voice.** Agent-facing prose has a higher bar than human prose; unhelpful sentences become instructions.

1. If the skill belongs to estack, edit it in the estack clone, not a loose `~/.claude/skills` or `~/.agents/skills` copy. Locate the clone by resolving this skill's real path and `git rev-parse --show-toplevel` (see `UPDATING.md`). Editing the repo is what makes the change reach both Claude Code and Codex.
2. Follow your platform's skill-authoring flow for writing SKILL.md files (for example, a `create-skill`-style draft/test/iterate loop if your platform has one).
3. Validate the skill: frontmatter has `name` and `description`, referenced files exist, and any cross-skill links resolve.
4. Test cases if structural; skip if subjective.
5. Commit and push from the estack clone, then run `scripts/refresh.sh` so both tools pick it up through the plugin install. Run **Opening a PR** when the change wants review; for your own repo a direct commit to a branch and push is fine.

When in doubt, delete; prose earns its keep by changing a decision. Match tone to scope. Point at structural sources (types, READMEs, config); hardcoded details go stale (the **encode-lessons-in-structure** principle skill). Delegate to other skills by path; don't restate. A workflow you keep hitting but isn't captured → propose a new skill.

**Reply:** summary of the skill, key design decisions, validation notes.
