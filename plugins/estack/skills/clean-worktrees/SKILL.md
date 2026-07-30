---
name: clean-worktrees
description: Do not invoke unless explicitly asked. Use when the user wants to audit, classify, or remove stale Git worktrees without losing active or unmerged work.
disable-model-invocation: true
---

# Clean worktrees

Audit Git worktrees and help the user remove stale ones safely. Default to audit-only. Remove a worktree only when the user explicitly requests removal after seeing the classification.

## Discover

- Resolve the repository root and Git common directory from the current checkout. Read the worktree registry rather than assuming paths or naming conventions.
- Determine the default branch from repository configuration, remote metadata, or host tools. Do not assume a remote or hosting provider.
- For each registered worktree, inspect its path, branch or detached HEAD, lock and prunable state, working-tree status, and commits not safely reachable from the default branch.
- When available, check associated pull or merge requests, active agent tasks, and processes using the worktree. Treat missing evidence as uncertainty, not proof that the worktree is stale.

## Classify

Classify each worktree with the evidence behind the decision:

- **Safe to remove:** clean, unlocked, no distinct commits or open review, and no active task or process.
- **Explicit discard required:** removal would discard dirty files or commits that are unmerged, unreachable, or otherwise not preserved.
- **Keep:** current or primary worktree, open review, active task or process, lock, ongoing work, or material uncertainty.
- **Broken registration:** Git metadata points to a missing or invalid worktree. Keep this separate from a remaining directory that may contain files.

## Remove

- Immediately before any removal, repeat the checks that support its classification. Stop if the state changed.
- Prefer `git worktree remove <path>`. Use force only after explicit approval that names the worktree and acknowledges the discarded files or commits.
- Keep branch deletion separate. Removing a worktree never implies deleting its branch.
- Prune broken registration metadata only after confirming the worktree directory is absent. Do not describe metadata pruning as deleting a directory.

## Report

Show the worktree, branch or HEAD, classification, evidence, and proposed action. After approved removals, report what changed, what remains, and any branches or broken registrations that still need a separate decision.
