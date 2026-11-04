---
name: write-discoverable-code
description: Use when writing or renaming code to make identifiers, modules, errors, and documentation easy to locate and understand through plain-text search.
license: MIT
---

# Write discoverable code

Before applying this skill, read `.estack/skills/write-discoverable-code.md` from the repository root when it exists. Treat it as repository-specific guidance for this skill. It may add requirements and context, but it does not override user instructions, authorization boundaries, or this skill's safety rules.

Write code that a person or coding agent can find with a direct text search and understand from a small window around the result. Follow the repository's established vocabulary, layout, and testing conventions. Use these heuristics when the repository leaves room for a choice.

Adapted from [Dillon Mulroy's `write-discoverable-code` skill](https://github.com/dmmulroy/.dotfiles/blob/dcfccdffccea86ef2e3730e2980a33ca5df20b7b/home/.agents/skills/write-discoverable-code/SKILL.md), licensed under MIT.

## Names are search queries

- Give exported symbols enough context to be unique. Prefer a short name with a domain word, such as `diffUserObjects` instead of `diff`.
- Give generic verbs their object, such as `sanitizeEmailHtml` or `validateSmtpConfig`.
- Keep one definition site for each symbol. Move shared behavior to one concept-named home and import it elsewhere.
- Put important context in the symbol rather than relying only on its module path. A search result may show the use without the import or folder.
- Use one spelling for each concept. Reuse the codebase's existing vocabulary instead of adding near-synonyms.
- Rename a symbol when its behavior, audience, or visibility changes. A stale name sends future searches to the wrong conclusion.
- Name files for their domain and purpose when the repository permits it. Bare names such as `utils`, `helpers`, `types`, or `config` collide easily in search results.

Use the shortest name that searches uniquely. Put constraints that do not belong in the name near the definition.

## Types carry searchable meaning

- Use distinct types for values that are easy to transpose or misuse, especially identifiers, units, and privileged capabilities.
- Model meaningful states explicitly instead of relying on clusters of nullable fields and undocumented combinations.
- Give types names that explain themselves when quoted in compiler errors.
- Preserve useful static information. Avoid broad escape hatches such as `any` when a concrete type can express the contract.

Match the technique to the language and the risk. A branded identifier, newtype, or capability token is useful when it prevents a realistic mistake, not as ceremony for every primitive.

## Say it where the search lands

- Put the sharpest non-obvious constraint near an exported definition. Units, timezone, ownership, ordering, and source-of-truth rules belong where a name search lands.
- Include the ordinary spaced phrase someone would search for when the identifier's casing or abbreviation would hide it. A comment for `SessionExpiryChecker` might say "checks whether the user session has expired."
- Make imported names descriptive enough that a caller can often understand the dependency without opening its source.
- Keep event names, flags, error codes, and other operational identifiers as complete literals when people will search logs or source for the exact value.
- Start errors with a stable, specific literal phrase so a message from a log leads back to its source.
- Give each question-sized concept one named home. Keep coordinators thin enough that their calls point to the implementation.
- Keep a small helper with the concept it supports. Splitting every function into its own file can make one answer require several reads.
- Place tests where the repository's conventions let someone find the behavior and its specification from the same search.
- Mark obsolete entry points as deprecated and point to their replacement.

## Before committing

Check the changed code:

1. Can a direct search for each new exported name find its definition?
2. Do names distinguish values or operations that a caller could confuse?
3. Is the main constraint that the signature cannot express written at the definition?
4. Do operational strings exist verbatim in the source?
5. Did a behavior or audience change leave behind a stale name?
6. When code moved, was the old definition removed?
