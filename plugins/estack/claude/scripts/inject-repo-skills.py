#!/usr/bin/env python3
"""List the skills of the repositories attached to a Claude Projects thread.

A project thread starts one directory above the repositories attached to it,
for example in `/home/user` with clones at `/home/user/ti` and
`/home/user/estack`. Claude Code loads each repository's `CLAUDE.md` there but
not its `.claude/skills`, and it builds the skill list once at boot, so no hook
can register them as skills. What makes a skill trigger is its description
being in front of the model, so this hook injects each skill's name,
description, and the absolute path of its `SKILL.md`, and the model reads the
file when one applies.

Claude Code sets `CLAUDE_CODE_PROJECTS_SESSION` to `1` in project threads, and
the hook does nothing anywhere else: a session started inside a repository
registers that repository's skills itself. It scans the directories directly
under `CLAUDE_PROJECT_DIR` that are Git checkouts, and lists the `SKILL.md`
files in each one's `.claude/skills`. Paths are resolved through symlinks,
because a repository may link `.claude/skills/<name>` to a shared folder and a
skill's relative paths resolve against the folder it really lives in.

A skill that sets `disable-model-invocation: true` is listed by name and path
only, in a separate group. Claude Code keeps such a skill out of the model's
list and leaves it to the user's slash command, which a project thread does not
have for these skills, so the user can only ask for it by name.

The frontmatter is read line by line rather than with a YAML parser. PyYAML is
not in the standard library, and a frontmatter that is not strict YAML, such as
an unquoted `: ` inside a description, should still be listed.

It runs on the same events as `inject-home-instructions.py`, for the same
reasons: `/clear` and compaction drop hook context, and `SessionStart` context
does not reach subagents. When the full list is longer than Claude Code's cap
on one hook's additional context, the longest descriptions are shortened until
it fits, because a shortened description still triggers its skill and Claude
Code would otherwise replace the whole list with a short preview.
"""

import glob
import json
import os
import re
import sys

# Claude Code's limit on the additional context of one hook. Longer output is
# saved to a file and replaced by a preview that drops most of the text.
ADDITIONAL_CONTEXT_LIMIT = 10_000

BLOCK_SCALAR_INDICATORS = {">", ">-", ">+", "|", "|-", "|+"}


def main() -> int:
    if os.environ.get("CLAUDE_CODE_PROJECTS_SESSION") != "1":
        return 0

    event = json.load(sys.stdin)
    project_dir = os.environ["CLAUDE_PROJECT_DIR"]
    repos = []
    for entry in sorted(os.scandir(project_dir), key=lambda item: item.name):
        if not entry.is_dir() or not os.path.exists(os.path.join(entry.path, ".git")):
            continue
        skills = repo_skills(entry.path)
        if skills:
            repos.append((entry.path, skills))
    if not repos:
        return 0

    cap = max(len(skill["description"]) for _, skills in repos for skill in skills)
    text = render(project_dir, repos, cap)
    while len(text) > ADDITIONAL_CONTEXT_LIMIT:
        cap -= 1
        if cap == 0:
            sys.exit(
                f"The skill list for {project_dir} exceeds Claude Code's "
                f"{ADDITIONAL_CONTEXT_LIMIT}-character limit on hook context "
                "even without descriptions"
            )
        text = render(project_dir, repos, cap)

    json.dump(
        {
            "hookSpecificOutput": {
                "hookEventName": event["hook_event_name"],
                "additionalContext": text,
            }
        },
        sys.stdout,
    )
    return 0


def repo_skills(repo: str) -> list[dict]:
    """Return the skills in a repository's `.claude/skills`, sorted by name."""
    skills = []
    for path in glob.glob(os.path.join(repo, ".claude", "skills", "*", "SKILL.md")):
        fields = frontmatter(path)
        skills.append(
            {
                "name": fields.get("name") or os.path.basename(os.path.dirname(path)),
                "description": fields.get("description", ""),
                "path": os.path.realpath(path),
                "user_only": fields.get("disable-model-invocation", "").lower() == "true",
            }
        )
    return sorted(skills, key=lambda skill: skill["name"])


def frontmatter(path: str) -> dict[str, str]:
    """Return the top-level fields of a `SKILL.md` frontmatter as flat strings.

    Indented continuation lines are joined to their key with spaces, a `>` or
    `|` block scalar becomes its text on one line, and a value wrapped in
    matching quotes is unquoted.
    """
    with open(path, encoding="utf-8", errors="replace") as f:
        lines = f.read().splitlines()
    if not lines or lines[0].strip() != "---":
        return {}

    parts: dict[str, list[str]] = {}
    key = None
    for line in lines[1:]:
        if line.strip() == "---":
            break
        match = re.match(r"([A-Za-z0-9_-]+):(.*)$", line)
        if match:
            key = match.group(1)
            parts[key] = [match.group(2).strip()]
        elif key and line[:1] in (" ", "\t"):
            parts[key].append(line.strip())

    fields = {}
    for key, values in parts.items():
        if values[0] in BLOCK_SCALAR_INDICATORS:
            values = values[1:]
        value = " ".join(value for value in values if value)
        if len(value) >= 2 and value[0] == value[-1] == "'":
            value = value[1:-1].replace("''", "'")
        elif len(value) >= 2 and value[0] == value[-1] == '"':
            value = value[1:-1].replace('\\"', '"')
        fields[key] = value
    return fields


def render(project_dir: str, repos: list, cap: int) -> str:
    """Return the injected text, with each description cut to `cap` characters."""
    lines = [
        f"The repositories under {project_dir} have skills that Claude Code did "
        "not register in this session, so the Skill tool cannot load them. When "
        "one fits the task, or a repository's instructions name it, read its "
        "SKILL.md at the path given and follow it as you would a loaded skill."
    ]
    for repo, skills in repos:
        lines += ["", f"{repo}:"]
        for skill in skills:
            if skill["user_only"]:
                continue
            line = f"- {skill['name']} ({skill['path']})"
            if skill["description"]:
                line += f": {shorten(skill['description'], cap)}"
            lines.append(line)
        user_only = [skill for skill in skills if skill["user_only"]]
        if user_only:
            lines.append("Use these only when the user asks for one by name:")
            lines += [f"- {skill['name']} ({skill['path']})" for skill in user_only]
    return "\n".join(lines)


def shorten(description: str, cap: int) -> str:
    if len(description) <= cap:
        return description
    return description[: cap - 1].rstrip() + "…"


if __name__ == "__main__":
    raise SystemExit(main())
