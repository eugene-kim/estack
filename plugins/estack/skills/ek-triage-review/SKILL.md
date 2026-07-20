---
name: ek-triage-review
description: Use when the user pastes in or points to feedback from an outside source (a reviewer, another model, a linter, a colleague, a code review tool, an audit) and wants it acted on. Treats the feedback as a claim to test, not a verdict to obey.
---

# Triage review

Incoming feedback is a set of claims from a source with its own blind spots, incentives, and error rate. Some points will be right, some wrong, some right but not worth acting on. The job is to sort that out before touching any code.

## Approach

- Read the feedback in full before reacting to any single point. Split it into discrete claims; a paragraph often bundles several.
- For each claim, check it against the actual code, not the reviewer's description of the code. Reviewers (human or model) misread diffs, cite the wrong line, or describe behavior the code doesn't have.
- Classify each claim:
  - **Confirmed** - the code shows the problem the claim describes.
  - **Wrong** - the claim misreads the code, or the described problem doesn't exist.
  - **Overstated** - a real observation, but the severity or framing is off.
  - **Out of scope** - true, but not worth the change it implies (style preference, hypothetical edge case, unrelated cleanup).
  - **Unclear** - can't be verified without more context; needs a question, not an assumption.
- Do not let source authority substitute for verification. A claim from a senior reviewer, a paid tool, or a bigger model gets the same scrutiny as one from an anonymous comment.
- Watch for claims that assume a different design than the one actually chosen, since the fix there is to explain the tradeoff, not change the code.

## Output

Report the triage before making any change:

```markdown
## Triage

- [Confirmed] <claim> - <file:line, evidence>
- [Wrong] <claim> - <why it doesn't hold>
- [Overstated] <claim> - <what's actually true, what isn't>
- [Out of scope] <claim> - <why it's not worth doing>
- [Unclear] <claim> - <what's missing to decide>

## Proposed action

<what to change, in order, based only on Confirmed and Overstated items worth acting on>
```

Then act only on what the triage supports, and ask before proceeding if the proposed action is large or the user's intent is ambiguous.
