---
name: ek-plan
description: Use when the user wants an implementation plan for a PRD, issue, feature request, bug, or code change before development.
---

# Implementation Plan

Turn agreed requirements into a concrete, testable engineering plan.

## Approach

- Read the PRD, issue, discussion, or code context that defines the work.
- Do not invent product behavior. If a requirement is missing, either ask or mark it as an explicit open question.
- Base claims on evidence from the repo: cite files, APIs, tests, data paths, and constraints you find.
- Prefer a focused coherent change that satisfies the requirement.
- Plan the overall direction before implementation when practical. For work too large or uncertain to settle responsibly in one pass, plan in reviewed stages instead.
- Choose planning depth from risk and uncertainty. Consider product for the problem and outcome; architecture for system boundaries, contracts, and data flow; program design for types, signatures, call paths, files, and responsibilities; and delivery for sequencing and feedback. These are lenses, not required sections.
- Use lightweight design sketches when they expose consequential choices: pseudocode, example inputs and outputs, and Markdown `diff` fences for proposed file trees, call paths, types, or signatures. Use a rough mockup or concrete interaction example for visible product work when it settles ambiguity faster than prose. Sketch the proposed shape without writing the implementation in advance.
- Avoid speculative APIs, fallbacks, validators, parsers, abstractions, or compatibility layers unless the requirement or observed usage demands them.
- Choose implementation slices, PR boundaries, and user feedback points independently based on what each boundary should accomplish. Align them when useful, but do not force a one-to-one relationship.
- Consider observable vertical slices when exercising real behavior early would reduce risk. Use horizontal sequencing when dependencies or the nature of the work call for it. Split work only when the benefit outweighs the overhead.
- Identify where the real implementation should be exercised during delivery. Default to having the agent verify it and continue. Plan a user checkpoint only when trying or viewing a coherent state could materially affect later decisions; prefer a committed, reviewable state when practical.
- Include a verification step in every plan. Say what checks, tests, inspections, or manual validation would give confidence that the change works.
- For larger or riskier tasks, have agent(s) adversarially review the plan before implementation. Choose review scope based on task risk, ask them to look for incorrect assumptions, missed requirements, overreach, sequencing problems, and missing verification, then iterate on the plan.

## Output

Before choosing a plan location, find any editable PRD or other authoritative requirements document for the same feature. If one exists, add or update a clearly separated implementation plan in that document. Keep product requirements and implementation decisions separate within the document. If code exploration reveals a missing or changed requirement, surface it as a product question instead of silently rewriting product intent. Follow repository status and revision conventions when updating point-in-time documents.

Create a separate durable plan only when the user or repository explicitly requires one, the requirements document cannot be edited, or the plan spans multiple requirements documents. In that case, cross-link the documents and identify the authoritative requirements source. The existence of a `plans/` directory, plan length, or a desire to separate product and engineering sections is not enough reason to create another durable document.

When there is no editable requirements document, create the plan where it best fits the work. Keep it in the conversation, a temporary file, an issue, a PR description, or another workspace when it is mainly a working artifact. Save it in the repo only when future work should treat it as durable project knowledge.

Use Markdown as the canonical plan format. Add a focused Mermaid diagram when relationships, sequence, state transitions, data flow, or architecture are easier to understand visually than through prose. Use pseudocode or a Markdown `diff` when the shape of the program is the useful thing to review. These aids are optional; omit them when they would only restate simple prose.

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

End with the plan location or summary, adversarial review status for larger or riskier work, the verification step, and the most useful next skill, usually `ek-implement`.
