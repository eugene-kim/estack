@estack-instructions.md

# Background task chips

A chip created with `spawn_task` must be executable. The new session knows only
the chip prompt and starts in a fresh worktree based on `main`. Before spawning
one, confirm that every referenced file, document, branch, and symbol exists
where that session will look. A reference that exists only in the current
conversation, worktree, or an unnamed unmerged branch is dead.

Choose the preparation that fits:

1. Land the reference first. If the task needs work that is not on `main`, such
   as a new PRD or helper, commit and merge it before or soon after spawning the
   chip. Do not say the chip is ready until the reference is on `main`.
2. Base the task on a branch. If the task depends on unmerged work, name the
   branch in the prompt, state its condition, and tell the session to check it
   out or base its work on it.
3. Make the prompt self-contained. Inline small required context, including the
   exact snippet, paths, and constraints. Use the first or second option when
   the required context is too large.

If a chip's premise changes, withdraw it with `dismiss_task`. When a better
version exists, spawn the replacement before dismissing the stale chip.

# Fable sessions

@fable-lead.md
