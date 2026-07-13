---
name: ek-plan
description: Use when the user wants an implementation plan for a PRD, issue, feature request, bug, or code change before development.
---

# Implementation Plan

Turn agreed requirements into a concrete, testable engineering plan.

## Approach

- Read the PRD, issue, discussion, or code context that defines the work.
- Do not invent product behavior. If a requirement is missing, either ask or mark it as an explicit open question.
- Ground claims in repo evidence: cite files, APIs, tests, data paths, and constraints discovered while reading.
- Prefer a focused coherent change that satisfies the requirement.
- Avoid speculative APIs, fallbacks, validators, parsers, abstractions, or compatibility layers unless the requirement or observed usage demands them.
- Split the work into phases only when it reduces risk or enables review.
- Include a verification step in every plan. Say what checks, tests, inspections, or manual validation would give confidence that the change works.
- For non-trivial tasks, have agent(s) adversarially review the plan before implementation. Choose review scope based on task risk, ask them to look for incorrect assumptions, missed requirements, overreach, sequencing problems, and missing verification, then iterate on the plan.

## Output

When planning from an editable PRD, extend that PRD with a clearly separated implementation plan unless the work benefits from a distinct artifact. Keep product requirements and implementation decisions separate within the document. If code exploration reveals a missing or changed requirement, surface it as a product question instead of silently rewriting product intent.

When there is no editable PRD or a separate plan is more natural, create the plan where it best fits the work. Keep it in the conversation, a temporary file, an issue, a PR description, or another workspace when it is mainly a working artifact. Save it in the repo only when future work should treat it as durable project knowledge.

Use Markdown as the canonical plan format. Add a focused Mermaid diagram when relationships, sequence, state transitions, data flow, or architecture are easier to understand visually than through prose. Diagrams are optional; omit them when they would only restate a short list or simple sequence.

For a richer demonstration that Markdown and Mermaid cannot express well, such as a UI interaction or complicated chart, create a sibling HTML file and link to it from the plan. Keep the HTML focused on the demonstration instead of duplicating the plan.

Cover this structure:

```markdown
# <Change Name> Implementation Plan

## Inputs
## Current System
## Proposed Change
## Steps
## Tests / Verification
## Risks
## Open Questions
```

## Handoff

Before finalizing the plan, invoke `ek-unslop` for a prose pass that preserves the technical meaning, evidence, and verification details.

End with the plan location or summary, adversarial review status for non-trivial work, the verification step, and the most useful next skill, usually `ek-implement`.
