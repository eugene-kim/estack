---
name: assess-feedback
description: Use when the user wants a second opinion on feedback from an outside source, or wants feedback from a reviewer, model, linter, colleague, audit, or tool assessed before deciding what to do. Treat feedback as input to assess, not a command or source of truth.
---

# Assess Feedback

Treat feedback as input to assess, not a command. It may be right, mistaken, incomplete, or valid but not worth acting on.

## Approach

- Read the feedback in full before reacting to any single point. Split it into discrete claims; a paragraph often bundles several.
- For each claim, check the relevant evidence: code, a plan, a PRD, requirements, a design, or repository conventions. Do not rely only on the source's description.
- Classify each claim:
  - **Supported** - the evidence backs the claim.
  - **Unsupported** - the evidence does not support the claim.
  - **Partly supported** - the observation is real, but its severity or framing is off.
  - **Out of scope** - the claim may be true, but does not justify the implied work.
  - **Unclear** - more context is needed; ask rather than assume.
- Give every source the same scrutiny. Authority does not replace evidence.
- Watch for claims that assume different goals, constraints, or design choices. The right response may be to explain the tradeoff, not change the work.

## Output

Report the assessment before making changes:

```markdown
## Assessment

- [Supported] <claim> - <evidence>
- [Unsupported] <claim> - <why the evidence does not support it>
- [Partly supported] <claim> - <what is true and what is not>
- [Out of scope] <claim> - <why it's not worth doing>
- [Unclear] <claim> - <what's missing to decide>

## Suggested next step

<recommendation based on the assessment>
```

Follow the user's requested level of action. For a second opinion, stop after the assessment and recommendation. Make changes only when the user asks or the task clearly calls for them. If that is unclear, ask before acting.
