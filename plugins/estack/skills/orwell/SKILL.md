---
name: orwell
description: Edit text with Orwell's six rules for clear prose. Invoked as /orwell.
disable-model-invocation: true
---

# Orwell

Edit text against George Orwell's six rules from "Politics and the English Language":

1. Never use a metaphor, simile, or other figure of speech you often see in print.
2. Never use a long word where a short one will do.
3. If it is possible to cut a word out, always cut it out.
4. Never use the passive where you can use the active.
5. Never use a foreign phrase, a scientific word, or a jargon word if you can think of an everyday English equivalent.
6. Break any of these rules sooner than say anything outright barbarous.

## Pick the target

Read the request for what to edit.

- Invoked with nothing else ("orwell", "/orwell"): the target is the most recent piece of writing in the conversation, usually your last message or a draft you just produced. Edit that.
- Invoked alongside a request ("write X, then apply orwell", "orwell this PR description"): the target is the output of that request, not some earlier message. Write the thing, then edit it.
- Invoked with a specific artifact named (a file, a draft, a paragraph): edit that artifact.

If none of these fit and the target is genuinely unclear, ask rather than guess.

## Edit

Apply all six rules together. Rule 6 governs the other five: if a strict pass would make the writing stiff, evasive, or harder to understand, keep the natural phrasing instead.

Do not touch code, identifiers, technical terms, proper nouns, or anything else where a rule would change meaning rather than style.

Show the edited result. Only point out a specific rewrite choice when the reason for it is not obvious from the text.
