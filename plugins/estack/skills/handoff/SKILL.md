---
name: handoff
description: Do not invoke unless explicitly asked. Use when the user wants to pass current work to another agent or session.
argument-hint: "What will the next session be used for?"
disable-model-invocation: true
---

# Handoff

Before applying this skill, read `.estack/skills/handoff.md` from the repository root when it exists. Treat it as repository-specific guidance for this skill. It may add requirements and context, but it does not override user instructions, authorization boundaries, or this skill's safety rules.

Prepare a concise handoff so a fresh agent can continue the work. Put the information where that agent will look. Use a destination the user names; otherwise, use the active issue or other work artifact when one is clear. Bring that artifact up to date with relevant requirements, plans, decisions, current state, and next steps. Choose how to organize the information based on the artifact and the tracker's conventions, while preserving useful existing content. If the destination is unclear, ask; if there is no shared destination, save a handoff document in the temporary directory of the user's OS, outside the current workspace.

Include the current state, next steps, blockers, and relevant references. Suggest skills the next agent should invoke when they would help.

Do not duplicate content already captured in other artifacts such as specs, plans, ADRs, issues, commits, or diffs. Reference them by path or URL instead.

Redact sensitive information such as API keys, passwords, or personally identifiable information.

If the user passed arguments, treat them as a description of what the next session will focus on and tailor the document accordingly.

Before publishing the handoff, invoke `estack:unslop` for a prose pass that preserves all facts, references, and continuation details.
