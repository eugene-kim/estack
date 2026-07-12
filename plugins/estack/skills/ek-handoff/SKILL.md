---
name: ek-handoff
description: Do not invoke unless explicitly asked. Use when the user wants to compact the current conversation into a handoff document for another agent or session to pick up.
argument-hint: "What will the next session be used for?"
disable-model-invocation: true
---

# Handoff

Write a handoff document summarising the current conversation so a fresh agent can continue the work. Save it to the temporary directory of the user's OS, not the current workspace.

Include a "suggested skills" section in the document that suggests skills the next agent should invoke.

Do not duplicate content already captured in other artifacts such as specs, plans, ADRs, issues, commits, or diffs. Reference them by path or URL instead.

Redact sensitive information such as API keys, passwords, or personally identifiable information.

If the user passed arguments, treat them as a description of what the next session will focus on and tailor the document accordingly.
