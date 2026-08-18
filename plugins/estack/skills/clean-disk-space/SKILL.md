---
name: clean-disk-space
description: Audit disk usage and propose safe, material cleanup across development tools, applications, caches, containers, Git worktrees, and user storage. Use when the user wants to understand or reclaim disk space on a machine.
---

# Clean disk space

Audit first. Measure free space, find meaningful candidates, and present a proposal. Delete nothing until the user explicitly approves named targets.

## Audit

- Detect the operating system, filesystem, available tools, and relevant machine configuration. Run only checks that apply. Do not carry assumptions from another machine.
- Prefer command-line inspection, lifecycle, and cleanup interfaces when the detected platform or application provides them. Do not assume one command is portable. Use GUI control only when no suitable CLI exists or as a requested fallback.
- Measure free filesystem space before estimating opportunities. Audit common storage areas such as the home directory, application data and caches, system temporary storage, development stores, containers, worktrees, package caches, and unusually large files. Keep the search bounded and prioritize material findings.
- Inspect ownership and purpose before judging size. A cache trades disk space for download, build, or startup time; its name alone does not make it disposable.
- Prefer allocated or reclaimable size over apparent logical size when the filesystem exposes both. Treat sparse files, snapshots, clones, and copy-on-write data as uncertain until measured with suitable filesystem-aware evidence.
- For each detected surface, read [conditional-checks.md](references/conditional-checks.md) and apply only its relevant safeguards.
- For Git worktrees, invoke `estack:clean-worktrees` and use its evidence and classifications. Do not replace its audit with a simpler age or branch-name rule.

## Proposal

Group findings in this order:

1. **Useful items to keep** - large items whose present value or regeneration cost supports keeping them.
2. **Protected or unsafe** - active, system-owned, uncertain, shared, locked, open, or otherwise unsafe targets.
3. **Strong native-cleanup candidates** - material reclaim available through the owning application or package manager.
4. **Optional caches** - regenerable data whose removal costs downloads, builds, indexing, or slower startup.
5. **User data for manual review** - projects, archives, media, downloads, or other content whose value only the user can judge.

For every candidate, report estimated reclaimable space, evidence, risk, regeneration or recovery cost, the preferred owner-native action, and required permission. Distinguish current size from space that is actually reclaimable now. Include useful items and protected findings so the proposal explains what was considered and kept.

## Execute

- Act only on the exact targets the user approved. Approval of one candidate does not authorize adjacent paths, broader cleanup, or later candidates.
- Immediately before each destructive action, repeat the checks that made it safe. Resolve exact paths, reject unresolved variables and globs, inspect relevant open processes, and stop if state or evidence changed.
- Prefer the owner application's supported CLI cleanup command over GUI control or manual deletion. Keep distinct actions and their permissions separate.
- Treat quitting or relaunching an application and rebooting the machine as disruptive. Propose each action and obtain permission before doing it.
- Measure free disk space after cleanup. Report what was removed, measured space recovered, what remains, and whether recovery is possible.
