---
name: ek-explain
description: "Use when the user asks for a rich explanation of a code change, diff, branch, PR, concept, architecture, PRD, or plan. Produces HTML output."
disable-model-invocation: true
---

# Explain

Make a rich, interactive explanation of the specified subject. The subject may be a code change (diff, branch, commit, PR), a concept, a system's architecture, a PRD, or a plan. If the subject or its type is ambiguous, ask before writing.

## Output

Output a single self-contained HTML file that includes CSS and JavaScript. Make the whole thing one long page with section headers and a table of contents. Do not use tabs for the top-level structure.

Put the file in a global place on the user's computer outside of the code repo. The filename must always start with today's date in `YYYY-MM-DD-` format so files stay time-sorted and out of version control.

Example:

```text
/tmp/2026-01-12-explanation-<slug>.html
```

## Format

`references/example-explanation.html` is a real explanation of this repo's own plugin and refresh machinery, and it carries the format. Read it before writing. It shows the table of contents, callouts, decision cards, diagrams, the interactive quiz, dark mode, and print rules for US letter paper. Match it rather than reconstructing those from a description. Treat it as a floor. Its subject has no user interface, so it demonstrates no UI diagram, and a subject that needs more than it shows should get more.

The page should read well on a phone.

**Diagrams.** Build a small set of diagram families and reuse them through the explanation, so the reader learns to read them once and then reads them everywhere. Two usually earn their place: a simplified drawing of the UI the reader sees, for UI changes, and a component diagram with concrete example data moving through it. Use HTML and CSS, never ASCII, with HTML lists for lists and semantic markup where it applies.

**Callouts.** Use them for key concepts, definitions, important edge cases, and anything the reader should walk away remembering.

**Print.** The printed page has to teach on its own: US letter `@page`, light colors, no heading or callout or diagram or quiz question split across a break, interactive-only controls hidden, and quiz answers expanded. Copy the example's print block rather than rebuilding it.

**Code blocks.** Every one needs `white-space: pre` or `white-space: pre-wrap` in its CSS, or the browser collapses the newlines into a single line. Scan each before saving.

## Writing

Write with the clarity and flow of Martin Kleppmann. Make it engaging and written in classic style. Transitions between sections should be smooth.

Before finalizing the explanation, invoke `ek-unslop` for a prose pass that preserves technical accuracy and teaching value.

Do not duplicate content already captured in other artifacts. Reference PRDs, plans, ADRs, issues, commits, diffs, or pull requests by path or URL when they already contain the detail.

If the subject is associated with a pull request, make every meaningful mention of that PR in the HTML a clickable link to the PR. Use the PR URL for labels such as `PR #123`, the PR title, and references in the table of contents, background, walkthrough, quiz feedback, or final metadata when they point to that PR.

## Research

Broadly explore before writing. What "explore" means depends on the subject:

- **Diff, branch, commit, or PR**: inspect that artifact and enough surrounding code to explain it accurately. Understand the existing system, the changed code, and the reason the change matters.
- **Concept**: find where it is implemented or used in this codebase, if anywhere, and pull in outside knowledge needed to explain it correctly.
- **Architecture**: read the real components, their boundaries, and how data actually flows between them. Do not describe an idealized architecture that the code doesn't match.
- **PRD or plan**: read the source document in full, plus the current code, systems, or constraints it proposes to change.

## Sections

`references/sections.md` holds the section set for each subject type, plus the shared Decision audit, Explore, and Quiz patterns. Read the set that matches your subject.

## Verification

Before delivering, test every displayed or copyable shell command exactly as rendered to the reader. For commands assembled by client-side JavaScript, render or open the HTML, read the resulting DOM text or clipboard payload, and, when safe, execute that exact string against the intended repository fixture. Source inspection of the JavaScript string is not sufficient because escaping can change across JavaScript, DOM, and shell layers.

This applies whenever the explanation includes runnable commands. A PRD or plan for not-yet-built work may have none, and then you skip this step.

Open the finished file and look at it before delivering. A rendering fault, a collapsed code block, or a quiz that does not respond is not visible in the source.

## Final reply

Reply with the absolute path to the generated HTML file and mention that it is outside the repo.
