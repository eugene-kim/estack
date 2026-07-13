---
name: ek-explain-diff
description: "Use when the user asks for a rich explanation of a code change, diff, branch, or PR. Produces HTML output."
disable-model-invocation: true
---

# Explain diff

Make a rich, interactive explanation of the specified code change.

## Output

Output a single self-contained HTML file that includes CSS and JavaScript. Make the whole thing one long page with section headers and a table of contents. Do not use tabs for the top-level structure. Basic responsive styling for phone viewing is useful.

Put the file in a global place on the user's computer outside of the code repo. The filename must always start with today's date in `YYYY-MM-DD-` format so files stay time-sorted and out of version control.

Example:

```text
/tmp/2026-01-12-explanation-.html
```

Include print styles so the file is easy to print on standard US letter paper:

- Add `@page { size: letter; margin: 0.75in; }`.
- Use print-friendly colors and avoid dark backgrounds in print.
- Avoid splitting headings, callouts, diagrams, and quiz questions across pages when practical.
- Hide or simplify interactive-only controls in print.
- Expand or reveal quiz answers and explanations in print so the printed document remains useful.

Before saving the file, scan each code block in the HTML source and confirm its CSS includes `white-space: pre` or `white-space: pre-wrap`.

## Writing

Write with the clarity and flow of Martin Kleppmann. Make it engaging and written in classic style. Transitions between sections should be smooth.

Before finalizing the explanation, invoke `ek-unslop` for a prose pass that preserves technical accuracy and teaching value.

Do not duplicate content already captured in other artifacts. Reference PRDs, plans, ADRs, issues, commits, diffs, or pull requests by path or URL when they already contain the detail.

If the diff is associated with a pull request, make every meaningful mention of that PR in the HTML a clickable link to the PR. Use the PR URL for labels such as `PR #123`, the PR title, and references in the table of contents, background, code walkthrough, quiz feedback, or final metadata when they point to that PR.

## Research

Broadly explore the surrounding code before writing. Understand the existing system, the changed code, and the reason the change matters. If the user names a branch, PR, commit, or diff, inspect that artifact and enough surrounding code to explain it accurately.

## Sections

### Background

Explain the existing system relevant to this change.

We do not know how much the reader already knows, so include:

- A deep background for beginners. Make it skippable if the reader is already familiar.
- A narrower background directly relevant to the change.

### Intuition

Explain the core intuition for the code change.

Focus on the essence, not the full details. Use concrete examples with toy data. Use figures and diagrams liberally.

### Code

Do a high-level walkthrough of the changes to the code. Group and order the changes in an understandable way.

### Explore

When useful, give the reader a practical way to experience, exercise, or interrogate the change rather than only reading about it. Choose a form that fits the change and the available environment.

This might be a runnable example, a before-and-after demonstration, a focused test or script, an interactive UI walkthrough, representative inputs and outputs, or another direct way to make the changed behavior observable. A test that fails before the change and passes after it can be useful, but do not require that technique when another demonstration communicates the behavior better.

Include the commands, steps, controls, or embedded interaction needed to follow along. Explain what to notice and how the observation connects to the change. If direct exploration is impractical, provide the closest useful verification or inspection path. Omit this section when it would be artificial or add no value.

When the change has a visible surface — a UI, a rendered report, generated HTML — exploring it must include viewing that surface: give the commands to render or serve it and say what to look at. Demonstrating such a change only through CLI output or tests is incomplete.

### Quiz

Come up with five questions that test the reader's knowledge of this PR or change.

The questions should be medium difficulty. They should be hard enough that the reader needs to understand the substance of the change to answer, but they should not be gotchas.

Present the questions as interactive multiple-choice questions. When the user clicks an answer, tell them whether they were correct and give feedback.

## Diagrams

Use a coherent set of diagram families that can be reused throughout the explanation to explain different cases.

Useful diagram types include:

- A simplified version of the UI the user sees in the app, for UI changes.
- A system diagram showing data flow or communication between components. Include example data.

Do not use ASCII diagrams. Use simple HTML designs for diagrams, HTML lists for lists, and semantic markup where possible.

## Code blocks

Use `<pre>` tags for code blocks.

If you use a custom styled `div` instead, its CSS must include `white-space: pre-wrap`; otherwise the browser will collapse newlines into a single line.

## Callouts

Use callouts for key concepts, definitions, important edge cases, and ideas the reader should remember.

## Final reply

Reply with the absolute path to the generated HTML file and mention that it is outside the repo.
