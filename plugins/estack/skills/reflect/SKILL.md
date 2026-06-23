---
name: reflect
description: Spawn three parallel review subagents over the active transcript, surface learnings, and route each to a concrete edit on an existing skill. Use when the user says reflect.
disable-model-invocation: true
---

# Reflect

Mine the current conversation for durable learnings, then route them into skill edits. Three reviewers read the transcript through different lenses. A synthesizer on a strong reasoning model applies named criteria. The parent presents the synthesizer's output to the user, then applies the approved subset.

## When to invoke

- The user said "reflect" or "/reflect".
- A complex task (5+ tool calls) just landed cleanly and the recipe is worth keeping.
- The agent hit dead ends, found the working path, and the path generalizes.
- The user corrected the agent's approach mid-task.
- A non-trivial workflow emerged that isn't captured anywhere.

Skip when the conversation is trivial, off-topic, or already covered by an existing skill the parent followed correctly. One-offs are not learnings.

## Process

### 1. Locate the active transcript

Find the transcript for the current conversation before fanning out. Stay inside
the active workspace or transcript location provided by the environment. Do not
search across unrelated project transcript locations; that crosses workspace
boundaries and may read private chats from other projects.

Prefer the real transcript path when you can identify it with high confidence.
If you cannot, write a tight digest of the current session and pass that to the
reviewers instead.

### 2. Spawn three reviewers in parallel

Launch three independent reviewer agents concurrently when the platform supports parallel agent runs. Assign an explicit model role to each and give reviewers the tool or MCP access needed for context lookups, such as tickets, chat threads, or observability traces referenced in the transcript. The prompt forbids file writes; the parent applies edits.

| Lens | Model role | Prompt template |
|---|---|---|
| Judgment | a strong reasoning model | `references/judgment-reviewer.md` |
| Tooling | a fast, lower-cost code model | `references/tooling-reviewer.md` |
| Divergent | a strong reasoning model | `references/divergent-reviewer.md` |

Pass each template verbatim, substituting the transcript path or digest where marked. Reviewers return findings in the subagent response body.

### 3. Synthesize

Launch one independent synthesizer agent on a strong reasoning model. Give it the tool or MCP access needed to spot-verify citations. Use `references/synthesizer.md` verbatim, with each reviewer's full output inlined where marked. The synthesizer returns a structured Accepted / Rejected / Backlog list.

### 4. Structural enforcement check

Sanity-check the synthesizer's Accepted list. For any item that would be enforced more reliably by a lint rule, script, metadata flag, or runtime check, move it from Accepted to Backlog. The synthesizer already applies this criterion; this is a final pass before edits land. See the **encode-lessons-in-structure** principle skill.

### 5. Apply

Before applying any Accepted edit, present the synthesizer's full Accepted/Rejected/Backlog output to the user and wait for explicit approval. The user picks which subset to apply and may redirect routings. Skill changes affect every future agent in the org; do not auto-apply.

Backlog items file to whatever devex / backlog tracker your team uses automatically. Those are tracker submissions, not skill edits. Only the Accepted list waits for approval.

For each approved skill edit, modify the source file under `<estack-repo>/plugins/estack/skills/...`. Do not edit the active copied skill under the Codex plugin cache, and do not edit a loose `~/.claude/skills` or `~/.agents/skills` copy. Locate the clone by resolving a skill's real path and `git rev-parse --show-toplevel` (see `UPDATING.md`). After the source edits are done, commit and push from that clone, then run `scripts/refresh.sh` so both tools pick up the plugin update.

For each approved Accepted item, follow the Routing field exactly:

- Trivial existing-skill edit (a one-line bullet, a tightened sentence, a stale fact corrected): parent edits the file in the estack clone directly.
- Substantive existing-skill edit (a new section, a new pattern table, more than ~10 lines): follow the authoring-a-skill playbook at `<repo>/plugins/estack/skills/euge-mode/playbooks/authoring-a-skill.md` (or your platform's skill-authoring flow), and run its draft / test / iterate loop.
- `tune description: <skill path>` (the skill exists but didn't trigger when it should have): edit the skill's description in the estack clone; run a description-optimization loop if your platform has one.
- `new skill: <kebab-name>`: create it under `<repo>/plugins/estack/skills/<kebab-name>/` in the estack clone. Do not invent the shape ad hoc; follow the authoring-a-skill playbook at `<repo>/plugins/estack/skills/euge-mode/playbooks/authoring-a-skill.md`.

For each Backlog item, file to whatever devex / backlog tracker your team uses.

If your environment ships a SKILL.md validator, run it on every touched skill before declaring done. Skip this step if it doesn't.

### 6. Summarize for the user

Short list, no preamble:

- Edits applied: `<skill path>`. What changed, one line each.
- New skills created: `<skill path>`. One line each (rare).
- Backlog filed to the devex tracker: `<issue title>` (`<tags>`). One line each.
- Dropped: one line per rejected finding + reason from the synthesizer.
