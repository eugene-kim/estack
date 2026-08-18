# Conditional checks

Use only the sections that match detected tools and storage surfaces. Confirm current commands and paths from the machine rather than assuming these examples apply unchanged.

## Nix

- Inspect the installed Nix, nix-darwin, Home Manager, generation, GC-root, and dotfiles setup before proposing changes. Prefer Nix-owned garbage collection over deleting store paths.
- Do not describe `nix store gc --dry-run` as perfectly read-only: it may prune stale GC-root or temporary-root metadata even when it deletes no store paths. Warn before using it, or use generation, root, and filesystem inspection when that evidence is enough.
- A dry run may report a path count without a useful size estimate. Measure filesystem space before and after approved collection, and retain the actual garbage-collection summary, including paths deleted and space reported freed.
- Require separate approval for `nix-collect-garbage -d` because it removes old generations. When recurring growth is the issue, suggest durable scheduled garbage-collection configuration in the machine's source-of-truth configuration.

## Git

- Use `git count-objects -vH` to distinguish loose objects, valid packs, and garbage such as temporary packs. Try owner-native `git gc` before considering manual removal.
- Never manually remove normal `.pack` or `.idx` files. If Git still reports one exact `tmp_pack_*` file as garbage after `git gc`, first confirm that no Git maintenance process or open handle uses it and that `git fsck --full --no-dangling` passes. Then propose exact removal with separate approval, without a glob, and rerun the integrity check afterward.
- Audit worktrees through `estack:clean-worktrees`, preserving its safe-removal, explicit-discard, keep, and broken-registration classifications.

## Homebrew

- Use `brew cleanup --dry-run` to inspect candidates. Run `brew cleanup` only after approval.

## VS Code

- When VS Code is installed, use its detected CLI to list installed extension versions, then inspect the actual extensions directory and `.obsolete` registry. Resolve each obsolete key to a directory and sum only directories that still exist; stale registry keys are metadata, not reclaimable extension space.
- Do not claim the CLI can remove one installed version: `--uninstall-extension` removes the extension. An approved launch, wait, and full quit is a fallback cleanup test or validation step, not an assumption that obsolete data will disappear. If application cleanup fails, prefer application-managed uninstall and reinstall before proposing exact manual deletion.

## Chrome and Chromium

- Treat `code_sign_clone` directories as copy-on-write code-sign snapshots that can keep a running application valid during staged updates. Find the exact per-user directory and inspect it with `lsof +D <exact-path>`.
- Never touch an active clone. Treat an approved quit or relaunch as a test: recheck exact count, open handles, timestamps, and allocated versus apparent size afterward. If inactive clones remain, propose an approved reboot before exact manual removal with separate approval.
- On APFS, explain that `du` can greatly overstate physically reclaimable space because clones share blocks.

## Containers

- For Docker-compatible runtimes, use `docker system df -v`. Separate active resources, resources reclaimable now, and idle resources that may still be useful.
- Check repository references and container or volume labels when practical. Do not broadly prune images, volumes, containers, or build cache by default. Prefer exact owner-native actions.
- Treat virtual disk images as possibly sparse. Report allocated space separately from logical capacity; a logically large image may occupy little physical storage.

## Package and runtime caches

- Explain download, rebuild, and startup costs. Use each package manager's supported inspection and cleanup commands when available; for npm, use its native cache commands rather than deleting cache internals.
- Judge install caches, language runtimes, browser downloads, model assets, and agent runtimes by recent use and regeneration cost. Do not encode another machine's keep-or-delete decision as a default.

## Application and project data

- Propose only exact, regenerable cache paths and confirm that no relevant process has them open. Do not blanket-delete a general cache directory such as `~/Library/Caches`.
- Treat Application Support, application containers, projects, archives, downloads, media, and unusually large files as owned data until evidence establishes a native cleanup path or the user approves manual review.

## Filesystem measurement

- Measure filesystem free space and inspect material areas such as user storage, application data, container stores, temporary directories, development stores, and unusually large files using tools suitable for the detected platform.
- On copy-on-write filesystems such as APFS, distinguish apparent size, allocated size, snapshots, clones, and space the filesystem can actually reclaim. State uncertainty instead of presenting logical size as a savings promise.
