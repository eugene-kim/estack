# estack

Skills in this repo must work in **both Claude Code and Codex**.

Tool-specific features are allowed — but when you use one, add an equivalent that produces the same behavior on the other tool. Don't drop a feature just because the other tool lacks it; pair it with a fallback.

**Example — manual-only skills.** Claude Code honors `disable-model-invocation: true` in frontmatter so the model never auto-invokes the skill. Codex ignores that field, so also encode the intent in the description (e.g. "Do not invoke unless explicitly asked"). The skill then behaves as manual-only on both tools.
