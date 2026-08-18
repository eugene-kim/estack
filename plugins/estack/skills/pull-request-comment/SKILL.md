---
name: pull-request-comment
description: Use when writing a comment on a pull request or merge request — a review comment, a reply, or a suggestion — on GitHub, GitLab, or any other platform.
---

# Writing pull request comments

## Write the comment directly

If you already have longer analysis of the problem, do not compress it into a
comment. Compression keeps the shape of the long version and drops the step that
mattered. Write the comment from scratch instead.

## Assume the reader knows the code

Do not explain the subsystem. State the defect. Background the reader already
has is the largest source of unnecessary length.

## Structure

Short comments need no structure. Say the thing and stop.

Longer comments have three parts:

1. **Summary** — one or two sentences stating the whole problem. Format it bold.
2. **Body** — the mechanism, then the evidence. No formatting.
3. **Suggestion** — labeled exactly `**Suggestion:** …`

Most comments should carry a suggestion. If there genuinely isn't one, the
comment is probably a question instead.

## The summary

- It must describe the whole problem on its own. Someone who reads only the
  summary should know what is wrong and why it matters. A topic label is not a
  summary.
- State the defect. Do not orient the reader to the subsystem.
- Keep measurements, counts and timings out of it. Those go in the body. The
  summary frames the problem; the body proves it.

## Language

Hold every comment to the plain-language bar in `estack:bro`: represent the
problem's real complexity faithfully, but do not add complexity through
jargon, structure, or wording, and keep the details, evidence, and caveats
that matter.

- Plain and direct. If a shorter, more ordinary word exists, use it. Prefer the
  everyday phrase over the technical-sounding one.
- No editorializing. Give the mechanism and the consequence, then stop. Do not
  say something is dangerous, surprising, subtle or easy to hit. If the
  mechanism is clear, the reader concludes that themselves.
- Cut restatement. The most common flaw in a first draft is explaining the same
  mechanism twice in different words.
- Use the vocabulary the team uses for a component, not the vocabulary of what
  is inside it. Naming an internal library or module can be technically accurate
  and still mislead someone who thinks about that component differently.
- Be precise about scope. Avoid vague collective nouns — "everything in the
  job", "the whole batch", "all the records". Say exactly what is affected: one
  item, one request, every item of that type, every subsequent run.
- Code identifiers, file and line references, status codes, error names and
  config keys stay verbatim. They are names, not jargon, and shortening them
  loses information.

## What to cut

Keep a sentence only if the reader needs it to do one of three things:

1. Believe the finding.
2. Locate it.
3. Act on it.

Everything else goes. This covers editorializing, restatement, and background
the reader already has.

## Keep the evidence

Cutting for length does not apply to evidence or caveats. They read like filler
and are the opposite — the reader may disagree, and evidence is what settles it.
Keep the number; cut the sentence explaining what the number implies.

- Cite specifics: file and line, the measured value, the test that does or does
  not cover the case.
- **Every example must be real.** Never invent a field name, a permission, a
  config value or a failure mode to make an example concrete. An invented detail
  is usually the most persuasive-sounding part of a comment, which is what makes
  it damaging. If a specific cannot be verified, construct the example so it
  does not need one.
- Verify each claim against the current state of the branch, and know which
  revision you are describing. Code moves between review rounds.
- Do not pass along a finding you have not checked yourself. If it came from a
  tool, another agent or an earlier pass, confirm the mechanism in the code
  before asserting it.
- If a claim turns out wrong or overstated, correct it in a sentence and
  continue. Do not defend it, and do not pad the correction with apology.

## Suggestions

- Recommend one option and give the reason. Do not present a menu of equally
  weighted choices.
- Name the property that should hold, not only the edit that achieves it. "These
  two paths should arrive at the answer the same way" is the durable point; the
  line change follows from it. A suggestion framed as a principle also says when
  a different fix would be acceptable.
- Prefer a fix that removes the possibility of recurrence over one that patches
  the current instance, and say which you are proposing.

## Existing discussion

- Read the existing discussion before writing. Do not raise something already
  addressed, and do not re-raise something explained as a deliberate decision.
- Where someone has documented their reasoning, engage with that reasoning
  directly rather than restating the original objection. If the reasoning rests
  on a false premise, that is the finding — say so and show why.
- Judge pushback on the merits. Sometimes a refusal is correct, and saying so
  plainly is worth more than pressing.
