# Plan

Produce a phased implementation plan grounded in the **Principles** section of the `euge-mode` skill. The plan is the deliverable. Do not implement.

Open a todolist with one item per step below.

## 0. Triage

Skip the plan when the change is one or two files with an obvious approach. Say so and stop.

Plan when the change spans three or more files, introduces architecture, has competing approaches, has unclear scope, or the user asked for one.

## 1. Re-read principles

Read the **Principles** section of the `euge-mode` skill end to end, and the leaf `principle-*` skills it indexes. The principles govern every plan decision; cross-link them.

## 2. Scope and constraints

State your read of scope and constraints in one paragraph. Ask the user only for genuinely ambiguous intent (the **never-block-on-the-human** principle skill); give concrete options with each open question.

Resolve what is in scope vs explicitly out, technical or platform constraints, patterns to preserve, and the definition of done.

## 3. Explore in subagents

Delegate codebase exploration (the **guard-the-context-window** principle skill).

- Prefer the platform's estack or euge-mode agent profile when one exists. Otherwise use a general-purpose agent and have it read `euge-mode` first. Avoid platform planner agents that ignore this skill.
- Pick the model by role: a fast, lower-cost code model for code reads, a strong reasoning model for judgment. Don't hardcode model names.

Each explorer returns file pointers, conventions, dependencies, test infrastructure, and entry points. No inlined dumps.

## 4. Write the plan

The user specifies where the plan lives.

Use a single file `NN-slug.md` for small plans. For plans with three or more phases, use a directory with `overview.md` plus phase files:

```
NN-slug/
├── overview.md
├── phase-1-scaffold.md
├── phase-2-...md
└── testing.md
```

### Phase sizing

- One function or type plus tests, or one bug fix. Not "one file"; file sizes vary too much.
- Two to three files touched, max.
- Prefer eight to ten small phases over three to four large ones to preserve option value (the **foundational-thinking** principle skill).
- Split if a phase has more than five test cases or three functions.

### Overview file

- **Context.** Problem and why now.
- **Scope.** Included; explicitly excluded.
- **Constraints.** Technical, platform, dependency, pattern.
- **Alternatives.** Two or three approaches sketched, choice and rationale (the **exhaust-the-design-space** principle skill). Skip when constraints dictate one.
- **Applicable skills.** Domain skills the implementer should invoke, by name.
- **Phases.** Ordered standard-markdown links to phase files.
- **Verification.** Project-level commands.
- **Implementation guidance.** Per section 6.

### Phase files

- Back-link to overview.
- **Goal.** What the phase accomplishes.
- **Changes.** Files affected and the change at a high level. What and why, not how. No code snippets.
- **Data structures.** Name the key types or schemas. One-line sketch only (the **foundational-thinking** principle skill).
- **Verification.** Per section 6.

Order phases so infrastructure and shared types land first (the **foundational-thinking** principle skill). Each phase should be independently shippable.

For changes touching existing code, apply the **redesign-from-first-principles** principle skill: if we'd built this with the new requirement on day one, what would it look like? Redesign holistically; deliver incrementally.

If a phase creates or edits a skill, the phase instructs the implementer to use the **authoring-a-skill** playbook (or your platform's skill-authoring flow) for writing SKILL.md files.

## 5. Verification per phase

Each phase needs both:

**Static.** Type check, lint, project tests pass.

**Runtime.** Exercise the feature on the matching surface via the relevant control skill:

- For browser / web UIs: use your UI control skill, if you have one
- For CLIs and TUIs: use your CLI/TUI control skill, if you have one
- For native mobile: use whatever simulator-driving skill your team has
- If your surface has no control skill, flag it in the plan.

For bug fixes, the loop is reproduce on the surface, fix, verify on the same surface. Unit tests show a branch behaves a certain way. They do not prove the bug is gone (the **prove-it-works** principle skill).

If a touched surface has no control skill, flag it in the plan.

## 6. Implementation guidance

In the overview, name which euge-mode non-negotiables the implementer must apply, by name:

- the **how** skill over each unfamiliar subsystem before changing it.
- the **interrogate** skill for adversarial review on contested designs before shipping.
- the **unslop** skill over each diff before commit, and over any prose surface.
- the **show-me-your-work** skill to keep a decision trail when the plan is large enough to need an auditable record.
- drive follow-ups in a loop (your platform's loop command) after opening the PR.

## 7. Hand back

Summarize phases, scope boundaries, applicable skills, and verification. Stop. The user decides when implementation starts.
