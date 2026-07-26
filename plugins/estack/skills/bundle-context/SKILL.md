---
name: bundle-context
description: Do not invoke unless explicitly asked. Use when the user wants to package all repository, code, diff, issue, PR, log, instruction, and question context needed for an external model, reviewer, or fresh agent that cannot access the repo or prior conversation.
disable-model-invocation: true
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

Create a `QUESTION.md` at the bundle root. Put the user-facing question and all bundle metadata there:

- the exact question or task for the external model, including what kind of answer is wanted
- how to use the bundle
- a reading order that starts with the files most important for framing the question
- every included artifact in the zip with its source path, URL, command, or reason for inclusion
- important assumptions, constraints, open questions, omitted context, redactions, and verification evidence

Then create `repo-context.zip` containing the artifacts needed to answer without guessing. This may include relevant repo instructions such as `AGENTS.md`, `CLAUDE.md`, local contributor docs, source files, tests, schemas, migrations, configs, fixtures, generated examples, logs, issues, PR descriptions, review comments, commits, diffs, or command output.

Prefer exact copied files or faithful excerpts with source paths and line ranges. For large files, include the relevant excerpts plus enough surrounding context to make them understandable.

## Zip

Always package repository context as a zip. The external recipient should get the bundle folder's `QUESTION.md` and `repo-context.zip`.

ChatGPT-style uploads may have a 512 MB file limit. Keep `repo-context.zip` under 512 MB. If the archive is too large, narrow what goes into the zip: remove irrelevant large files, add repository-specific exclusions, or replace whole files with faithful excerpts that preserve source paths and line ranges. Do not switch to loose files as the primary bundle format.

Use a Git-aware file list as the default starting point so `.gitignore` is respected:

```bash
repo="/path/to/repo"
name="$(basename "$repo")"
out="${TMPDIR:-/tmp}/$(date +%F)-context-bundle-$name"
mkdir -p "$out"

git -C "$repo" ls-files --cached --others --exclude-standard \
  | sed "s#^#$name/#" \
  | rg -v "^$name/(\\.git|\\.claude|\\.codex)(/|$)|(^|/)node_modules(/|$)|(^|/)\\.env(\\.|$)" \
  > "$out/filelist.txt"

(
  cd "$(dirname "$repo")"
  zip -q "$out/repo-context.zip" -@ < "$out/filelist.txt"
)
```

Adjust exclusions for the repository. Common additions include local caches, virtual environments, build outputs, large generated artifacts, local databases, coverage reports, or any private files that are not needed for the question.

Check the archive size:

```bash
du -h "$out/repo-context.zip"
```

Verify the archive before relying on it:

```bash
zipinfo -1 "$out/repo-context.zip" \
  | rg '(^|/)\.git(/|$)|(^|/)\.claude(/|$)|(^|/)\.codex(/|$)|(^|/)node_modules(/|$)|(^|/)\.env(\.|$)'
```

No output means the baseline exclusions were not present in the archive.

## Redaction

Redact secrets, credentials, API keys, tokens, private personal data, and irrelevant sensitive details. Note that redaction happened when it affects interpretation.

## Validation

Before finishing, deploy a fresh agent to inspect the bundle. Give the agent essentially zero context beyond the bundle path and this task:

```text
Inspect the context bundle at <bundle-path>. Assume you have no access to the original repository, prior conversation, hidden agent context, GitHub, local files, or tool outputs except what is inside this bundle. Say whether the bundle is self-evident enough for an external model or fresh agent to answer the question. If it is not, list the missing or unclear context precisely.
```

The validation agent should judge:

- Can the recipient understand the question?
- Can they see the repo instructions that matter?
- Can they inspect `repo-context.zip` and find the important code or evidence directly?
- Are file paths, URLs, branch names, commits, and commands clear?
- Is the reading order enough to avoid wandering?
- Are omissions and assumptions explicit?

If the validation agent says the bundle is not clear, update the bundle and run another fresh-agent validation pass. Loop until the validation agent says the bundle is clear enough, or until the remaining gaps are impossible to fill and are explicitly documented in the bundle.

## Finish

End with the absolute path to the bundle, the `repo-context.zip` size, a brief summary of what it contains, the validation result, and any caveats about omitted or redacted material.
