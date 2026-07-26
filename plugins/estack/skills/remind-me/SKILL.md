---
name: remind-me
description: Use when the user asks to be reminded about, caught up on, or brought up to speed on a codebase, system, feature, issue, pull request, decision, concept, or prior work. Explain in the conversation without creating an artifact.
disable-model-invocation: true
---

# Remind Me

Bring the user up to speed in the conversation. Do not create a separate
artifact unless the user asks for one.

Derive the frame from the request and available context. Do not assume that
something changed. Explain the subject's purpose, relevant context, how it
currently works, and its present state. When prior work or changes matter,
explain what changed and why.

Investigate enough of the real source, history, discussion, or linked artifacts
to give a grounded account. Separate verified facts from inference.

Focus on what the user needs to understand, evaluate, or decide. Cover
important behavior, boundaries, interfaces, decisions, unresolved questions,
and risks when they matter. Do not narrate every file or repeat detail that
does not help the user regain context.

Point to useful source files, commits, issues, or pull requests when they help
the user go deeper. Suggest a reading order when the subject spans several
artifacts.

Match the depth to the request. Start with a clear overview, then add the
details needed to make the current state intelligible. Leave room for focused
follow-up questions.
