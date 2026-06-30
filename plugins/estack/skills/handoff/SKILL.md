---
name: handoff
description: "Compact the current conversation into a handoff document for another agent to pick up."
argument-hint: "What will the next session be used for?"
disable-model-invocation: true
---

# Handoff

Write a handoff document summarizing the current conversation so a fresh agent can continue the work.

Save the document to the temporary directory of the user's OS, not the current workspace. Use the platform's temp directory convention, such as `$TMPDIR` on macOS or Linux when available. Include the absolute path in the reply.

If the user passed arguments, treat them as the next session's focus. Tailor the document toward that use.

## Contents

Include:

- Current goal and status.
- Important decisions made in this conversation.
- Files, commits, PRs, issues, plans, ADRs, or other artifacts the next agent should read.
- Commands already run and their relevant outcomes.
- Open questions, risks, or next steps.
- Suggested skills the next agent should invoke.

Do not duplicate content already captured in other artifacts such as PRDs, plans, ADRs, issues, commits, or diffs. Reference them by path or URL instead.

## Redaction

Redact sensitive information before writing the document. This includes API keys, passwords, access tokens, secrets, private keys, personally identifiable information, and any credential-like strings from tool output or files.

When unsure whether a value is sensitive, redact it and describe the kind of value instead.
