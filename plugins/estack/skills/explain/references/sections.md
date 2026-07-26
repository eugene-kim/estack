# Section sets and shared patterns

Pick the set that matches the subject. Adapt section names and add or drop
sections when the subject calls for it. These are starting points, not a rigid
template.

## Diff, branch, commit, or PR

**Background.** Explain the existing system relevant to this change. We do not know how much the reader already knows, so include a deep background for beginners (skippable if familiar) and a narrower background directly relevant to the change.

**Intuition.** Explain the core intuition for the code change. Focus on the essence, not the full details. Use concrete examples with toy data. Use figures and diagrams liberally.

**Code.** Do a high-level walkthrough of the changes to the code. Group and order the changes in an understandable way.

**Decision audit.** See the shared pattern below.

**Explore.** See the shared pattern below.

**Quiz.** See the shared pattern below.

## Concept

**Background.** What problem the concept solves and what came before it.

**Intuition.** The core mental model, with concrete examples. This is the heart of a concept explanation, so spend the most effort here.

**Mechanics.** How it actually works, step by step, at the level of detail the reader needs to use it correctly.

**Application.** Where and how it shows up in this codebase or in practice, with real or realistic examples. Omit if the concept is purely theoretical for this audience.

**Quiz.** See the shared pattern below.

## Architecture

**Overview.** The components involved and the boundaries between them.

**Data flow.** How a request or a piece of data actually moves through the system, with a diagram and example data.

**Decision audit.** See the shared pattern below. Focus on structural choices: why components are split this way, why a boundary sits where it does, what it costs to change later.

**Explore.** See the shared pattern below. Favor observing the real system (logs, tracing, hitting a real endpoint) over reading source.

**Quiz.** See the shared pattern below.

## PRD

**Problem and goals.** What the PRD says is broken or missing, and what success looks like.

**Proposed solution.** The core approach, explained with the same intuition-first treatment as a concept.

**Scope and non-goals.** What's explicitly in and out, and why the line is drawn there.

**Decision audit.** See the shared pattern below. Treat contested calls in the PRD as decisions to audit, not settled facts.

**Open questions and risks.** What the PRD itself flags as unresolved, plus any the author didn't flag but the reader should know about.

**Quiz.** See the shared pattern below.

## Plan

**Goal and context.** What the plan is trying to accomplish and why, linking back to the PRD or issue that motivated it.

**Approach and sequencing.** The steps or phases, in order, and why that order was chosen.

**Decision audit.** See the shared pattern below. Focus on sequencing choices, chosen tools or libraries, and anything the plan defers or explicitly avoids doing now.

**Risks and mitigations.** What could go wrong at each phase and what the plan does about it.

**Definition of done.** How the reader will know the plan succeeded.

**Quiz.** See the shared pattern below.

## Shared patterns

### Decision audit

Expose the consequential choices behind the subject. Focus on choices where a reasonable alternative could materially affect correctness, scope, performance, maintainability, or future behavior. Omit mechanical implementation details.

When the author's conversation, handoff, or other context is available, ask: "Which consequential choices did you make that you are not confident of? List all." Include those choices. Without author context, identify likely choices from available evidence and label them as inferences. Do not claim to know the author's reasoning when you only have the artifact itself.

For each decision, explain the choice, supporting evidence or constraint, important assumptions or limits, and the reviewer question that would validate or challenge it. Include alternatives when they help the reader judge the choice. Present the audit as easy-to-scan decision cards or a table, linked to the relevant code, test, artifact, or exploration.

### Explore

Make Explore an interactive show-and-tell through the subject's real interface, not a source-reading guide. Choose an interaction that fits the subject. For UI work, explain how to open and use the real UI and what behavior to try or observe. For backend or library logic, use a focused input/output exercise or a reversible fail/pass demonstration when useful. For a generated report, render and manipulate or view the real report. Put source inspection and commands whose only purpose is `sed`, `rg`, or opening files in the Code walkthrough instead. Include setup or source-reading commands here only when needed to perform the interaction; they are not themselves the exploration. Do not reimplement production behavior in HTML when the repository is available.

Use embedded HTML interactions to navigate, filter, or visualize captured evidence. Do not use them to simulate business logic that the actual code can exercise.

One useful backend or library pattern is a fast fail/pass exercise:

1. Begin with `git status --short` and establish that every path the exercise may touch is clean.
2. Make one small, purposeful, reversible change and ask the reader what they predict.
3. Run the narrowest real command and observe a meaningful failure or behavior change. Inspect the output and `git diff`, then explain what the observation demonstrates.
4. Restore every modified or regenerated path, rerun the command, and observe the pass or restored behavior.

Prefer a disposable worktree when the exercise modifies files. If the current worktree is used, offer `git restore -- <explicit paths>` only for paths established as clean before the exercise. Never tell the reader to restore a path that was already dirty. Include exact setup, run, observation, diff, and cleanup commands without expanding into generic Git instruction.

Direct exploration is sometimes impractical, as with a PRD or plan for work that doesn't exist yet. Then provide the closest useful verification or inspection path, such as exploring the current system the work will change, or omit this section when it would be artificial or add no value.

Some subjects have a visible surface, such as a UI, a rendered report, or generated HTML. Exploring those must include viewing that surface: give the commands to render or serve it and say what to look at. Demonstrating such a change only through CLI output or tests is incomplete.

When practical, use an exploration to exercise a material assumption or limit from the Decision audit, not only the happy path.

### Quiz

Come up with five questions that test the reader's knowledge of the subject.

The questions should be medium difficulty. They should be hard enough that the reader needs to understand the substance of the subject to answer, but they should not be gotchas.

Present the questions as interactive multiple-choice questions. When the user clicks an answer, tell them whether they were correct and give feedback.

Include questions about consequential assumptions, limits, or tradeoffs as well as how the subject works or is structured.
