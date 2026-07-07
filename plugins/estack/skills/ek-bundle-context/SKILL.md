---
name: ek-bundle-context
description: Use when the user wants to package all repository, code, diff, issue, PR, log, instruction, and question context needed for an external model, reviewer, or fresh agent that cannot access the repo or prior conversation.
---

# Bundle Context

Create a self-contained context bundle for an external model, reviewer, or fresh agent.

## Assumption

Assume the recipient cannot see the repository, GitHub, local files, branches, `AGENTS.md`, `CLAUDE.md`, tool outputs, prior conversation, or hidden agent context unless the bundle includes it.

## Destination

Create the bundle outside the repo in the user's OS temporary directory. Use a dated, descriptive folder name.

Example:

```text
/tmp/2026-07-07-context-bundle-<slug>/
```

## Contents

Include what the recipient needs to answer the user's question without guessing:

- `QUESTION.md`: the exact question or task for the external model, including what kind of answer is wanted.
- `README.md`: how to read the bundle, what is included, what is omitted, and any important assumptions.
- `MANIFEST.md`: every included artifact with its source path, URL, command, or reason for inclusion.
- Relevant repo instructions such as `AGENTS.md`, `CLAUDE.md`, local contributor docs, or narrower module guidance when they affect the answer.
- Relevant source files, tests, schemas, migrations, configs, fixtures, generated examples, logs, issues, PR descriptions, review comments, commits, diffs, or command output.
- A short reading order that starts with the files most important for framing the question.
- Known constraints, open questions, and verification evidence.

Prefer exact copied files or faithful excerpts with source paths and line ranges. For large files, include the relevant excerpts plus enough surrounding context to make them understandable.

## Redaction

Redact secrets, credentials, API keys, tokens, private personal data, and irrelevant sensitive details. Note that redaction happened when it affects interpretation.

## Validation

Before finishing, inspect the bundle as if you were a fresh agent with no prior context:

- Can the recipient understand the question?
- Can they see the repo instructions that matter?
- Can they inspect the important code or evidence directly?
- Are file paths, URLs, branch names, commits, and commands clear?
- Is the reading order enough to avoid wandering?
- Are omissions and assumptions explicit?

If the bundle would force the recipient to ask for obvious missing context, add that context or explain why it is unavailable.

## Finish

End with the absolute path to the bundle, a brief summary of what it contains, and any caveats about omitted or redacted material.
