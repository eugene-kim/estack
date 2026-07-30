---
name: brief-task
description: Use before creating another Codex task or sending a message to an existing Codex task, to prepare a self-contained brief with the context, authority, source state, and success conditions the recipient needs.
---

# Brief task

Prepare the prompt for another Codex task before sending it. A new task does not inherit this conversation; an existing task keeps its own history. Supply the context needed for the recipient to make the same important choices expected from an agent that heard the relevant discussion.

## Authority

- This skill does not authorize creating a task. Create one only when the user has explicitly requested it. Send to an existing task only when the user or an in-scope workflow authorizes that communication.
- State whether the recipient should discuss, investigate, review, propose, or implement. Assessment does not imply permission to edit.

## Brief

Include the context that affects the recipient's choices:

- the concrete objective, why it matters, the current state, and what prompted the message
- decisions already made and their reasoning; rejected approaches when they prevent repeated debate or a known mistake
- scope, non-goals, known uncertainty, and unresolved decisions
- relevant repository, branch, commit, worktree, and dirty-state details
- files, URLs, diffs, issues, reviews, artifacts, or prior task results to inspect, with why each matters and a useful reading order when needed
- expected output, success conditions, required validation, and where to report the result

When correcting an earlier message, name the superseded instruction and say what to disregard.

## Access and source state

- Verify that the recipient can access every referenced local file and repository state. If not, include the needed excerpt or create an accessible artifact within the user's authorized scope.
- For a new repository task, state the required starting Git state. Do not assume a new worktree contains uncommitted changes.
- Prefer durable references for large material, but explain why each reference matters. A path or URL alone is not context.
- If task setup yields no usable task ID, follow the platform's setup and wait flow. Do not treat a queued identifier as a ready task.

## Calibration

Do not paste the whole conversation. Include history that changes decisions, scope, authority, or verification; omit history that does not change how the recipient should act. Preserve uncertainty. Match detail to complexity and risk without inventing a message-size limit or forcing empty sections.

Before sending, ask: Could the recipient make the same important choices we would expect from an agent that heard the relevant discussion?

After sending, tell the user what the brief covered. Name the objective, key constraints and decisions, and requested outcome rather than replying only that it was sent.
