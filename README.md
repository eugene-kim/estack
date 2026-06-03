# estack

> **Credit.** estack is my personal fork of [`pstack`](https://github.com/poteto/plugins/tree/main/pstack)
> by [Lauren Tan (poteto)](https://x.com/poteto), from the
> [poteto/plugins](https://github.com/poteto/plugins) repo, used here under the MIT
> license. pstack is the foundation; estack is my own copy that I'll keep modifying.
> The biggest change so far: the orchestrating skill `poteto-mode` is now `euge-mode`,
> and everything is de-Cursored and model-agnostic so it runs under Claude Code or Codex.

there's a growing sense that ai writes too much slop code. throughput without quality isn't the goal. if you want to go fast, go deep first.

**estack is a set of rigorous agent workflows.** the goal is not to maximize loc, it's the opposite: write less, but higher quality code.

**estack gives you fearless parallelism.** when you can go deep on one agent and trust it to write good, verifiable code, you can truly parallelize with confidence. start multiple agents up with `euge-mode` and trust that they'll apply rigorous engineering principles to their work.

**it's model-agnostic.** every frontier model has its strengths and weaknesses. the skills describe roles ("a strong reasoning model", "a fast, lower-cost code model", "a diverse panel of independent models") and let your platform pick the actual model. no hardcoded model names to maintain as new models ship.

fork it. improve it. make it yours.

## install

estack is a directory of skills (plus one subagent). the `SKILL.md` format works in both Claude Code and Codex.

**Claude Code.** This repo is a Claude Code plugin (see `.claude-plugin/plugin.json`). Add it as a plugin / via a local marketplace pointed at this repo, then `euge-mode` and the other skills load automatically.

**Codex.** Run the install script to symlink every skill into `~/.agents/skills`:

```bash
./scripts/install-codex.sh
```

Then invoke the orchestrator, e.g. `use euge-mode: <your task>`. See `AGENTS.md` for Codex-specific notes (subagents, model selection).

## make it yours

`euge-mode` is one style. you may not want exactly that.

use `/automate-me`. it mines your recent transcripts, drafts a `<your-name>-mode` skill from how you've actually worked, and routes through estack underneath. you keep estack as the base and end up with your own routing skill alongside `euge-mode`.

## usage

use `/euge-mode` at the start of a task. it reads your request, picks from a set of playbooks, and runs the other skills as the steps need them.

### just use `/euge-mode`

this is the main shortcut for any rigorous engineering work. it comes with fourteen playbooks:

| playbook | for |
|---|---|
| investigation | a read-only question. how does x work, why was y built this way, are we sure. |
| bug fix | reproduce a defect, root-cause it, and fix with runtime evidence. |
| perf | trace a measured slowness and improve it against a baseline. |
| runtime forensics | diagnose a live symptom (leak, idle-cpu spin, glitch) from instrumentation. |
| trace forensics | diagnose a captured profiling artifact (cpuprofile, trace, spindump, heap snapshot). |
| feature | new or changed behavior, built from a named data shape. |
| refactoring | a behavior-preserving change to structure or shape. |
| prototype | a throwaway sketch to make a design decision cheaply. |
| visual parity | pixel-exact ui equivalence between two implementations. |
| authoring a skill | writing or editing a SKILL.md. |
| eval | test how a skill or prompt change affects agent behavior, blinded. |
| autonomous run | drive a long task to completion without stopping. |
| session pickup | resume or take over a prior agent's in-flight work. |
| multi-phase plan | work that spans phases or stacked PRs. |

when invoked it:

1. opens a todo list. the first item is reading the inline principles index in the skill.
2. matches your task to a playbook and copies the steps in verbatim.
3. routes to the other skills as the steps fire.
4. writes unslopped replies.

the full rules and playbooks live in `skills/euge-mode/SKILL.md`.

`/euge-mode` works extremely well with a loop command (for example, Claude Code's `/loop`). you can drive an agent for hours without sacrificing rigor.

the rest are useful when you want to specifically invoke them:

| skill | use it when |
|---|---|
| `/euge-mode` | default entry point for any non-trivial task. |
| `/how` | you want a walkthrough of how a subsystem works. |
| `/why` | you want to know why something was built this way. discovers available MCPs at run time and queries each evidence category in parallel (source control, issue tracker, long-form docs, real-time chat, infra observability, error tracking, analytics warehouse). |
| `/architect` | you're about to write code that crosses a function boundary and want the types and module shape settled first. |
| `/arena` | you want N parallel attempts at the same thing, then to grab the best parts of each. |
| `/interrogate` | you have a diff and want several independent models to try to break it. |
| `/automate-me` | you want your own `-mode` skill, drafted from how you've actually worked. |
| `/reflect` | a long task landed and you want the recipe captured as a skill edit. |
| `/tdd` | you're fixing a bug and there's a cheap local test path. write the failing test first, then the fix. |
| `/typescript-best-practices` | you're reading or editing typescript. grounds the type-system-discipline principle in syntax. |
| `/figure-it-out` | no bundled playbook fits. designs a rigorous, auditable playbook for the task. |
| `/show-me-your-work` | you want a reviewable decision trail. logs decisions to a tsv you can commit. |
| `/unslop` | you're cleaning up writing. removes AI tells. |

### examples

mostly you type `/euge-mode` at the start of a task and let it route to a playbook. the other skills fire as the steps need them. a few you reach for directly.

```
bug fix:           /euge-mode this pr has a subtle bug where the scroll drifts every 750ms even
                   when idle. repro first, then fix and verify.
perf:              /euge-mode a big list takes a second or two to load even though we virtualize.
                   run a cpu trace and tell me why.
feature:           /euge-mode build a small feature behind a feature flag. verify it really works.
prototype:         /euge-mode build two prototypes of the markdown renderer so we can compare.
                   spawn an agent for each.
multi-phase:       /euge-mode open source these skills as a plugin. nothing internal leaks, work
                   in a temp dir, show me the dependency graph first.
overnight run:     /euge-mode i'm going to bed. land the stack even if ci flakes. i want
                   everything merged by morning.
visual parity:     /euge-mode the row spacing is too tall when this flag is on. the second image
                   is correct. repro and fix until it matches.
figure it out:     /euge-mode i'm stepping away. migrate every caller from the synchronous store
                   to the new async one, keeping behavior identical. i want to trust it was done
                   right when i'm back.
how:               /how do we cancel runs? do we have an n+1 when we look up every run to cancel?
why:               /why is this feature flag not on yet?
architect:         design this instrumentation to be high signal with no false positives. /architect
                   this first.
arena:             /arena take my prompt to the arena verbatim. i want to compare their proposals
                   with yours.
interrogate:       /interrogate review this pr.
tdd:               /tdd implement
unslop:            can we unslop and tighten the new changes?
reflect:           /reflect that took too long. capture what we learned so the next run doesn't
                   repeat it.
show-me-your-work: /show-me-your-work keep a decision trail i can review when i'm back.
automate-me:       /automate-me
```

## the `euge-agent` subagent

estack also ships a subagent that runs this style end to end. on Claude Code, spawn it from a parent agent via `subagent_type: "euge-agent"`. it reads `euge-mode` in full, including its inline principles index, before doing any work. substituting a plain general-purpose subagent skips that read and drifts.

`/euge-mode` and `subagent_type: "euge-agent"` route through the same wrapper. on Codex (no plugin subagent), use a general-purpose subagent and have it read `skills/euge-mode/SKILL.md` first.

## principles

nineteen short skills, one principle each. `euge-mode` indexes them inline and reads that index at task start. the standalone files are there so other skills can reference a principle by name, and so the index can point at the full rule for each.

- core: laziness-protocol, foundational-thinking, redesign-from-first-principles, subtract-before-you-add, minimize-reader-load, outcome-oriented-execution, experience-first, exhaust-the-design-space, build-the-lever.
- architecture: boundary-discipline, type-system-discipline, make-operations-idempotent, migrate-callers-then-delete-legacy-apis, separate-before-serializing-shared-state.
- verification: prove-it-works, fix-root-causes.
- delegation: guard-the-context-window, never-block-on-the-human.
- meta: encode-lessons-in-structure.

## not bundled here

a few things `euge-mode` references but doesn't ship:

- a dedicated **prose-cleanup** step beyond the bundled `unslop` skill. `unslop` is here and covers it.
- **control skills** for driving a live surface (a CLI/TUI control skill, or a browser/web UI control skill). estack doesn't bundle these; use your own if you have them, and the skills flag the gap when a surface has no control skill.
- a **loop** command for long, unattended runs. that's a platform feature (for example, Claude Code's `/loop`), not a skill.

## why are there no planning skills?

both Claude Code and Codex have plan modes that work well alongside estack. the best spec is often the code itself. if you do want a plan, `/euge-mode` covers it, but it's not the default.

## license

MIT. See [LICENSE](LICENSE) — original copyright Lauren Tan (pstack), modifications Eugene Kim (estack).
