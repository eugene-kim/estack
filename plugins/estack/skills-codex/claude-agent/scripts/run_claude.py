#!/usr/bin/env python3
"""Run one headless Claude turn and retain its streamed evidence."""

import argparse
import datetime
import json
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path


def utc_now() -> str:
    return datetime.datetime.now(datetime.UTC).isoformat()


def write_json(path: Path, value: dict) -> None:
    temporary = path.with_suffix(path.suffix + ".tmp")
    temporary.write_text(json.dumps(value, indent=2) + "\n", encoding="utf-8")
    temporary.replace(path)


def print_summary(value: dict) -> None:
    json.dump(value, sys.stdout)
    sys.stdout.write("\n")
    sys.stdout.flush()


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--assignment", required=True, type=Path)
    parser.add_argument("--cwd", required=True, type=Path)
    parser.add_argument("--model", required=True)
    parser.add_argument("--effort", required=True)
    parser.add_argument("--tools", required=True)
    parser.add_argument("--permission-mode", default="dontAsk")
    parser.add_argument("--resume")
    parser.add_argument("--chrome", action="store_true")
    mcp = parser.add_mutually_exclusive_group()
    mcp.add_argument("--no-mcp", action="store_true")
    mcp.add_argument("--mcp-config", type=Path)
    parser.add_argument("--claude-bin", default="claude", help=argparse.SUPPRESS)
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    cwd = args.cwd.resolve()
    assignment_source = args.assignment.resolve()
    if not cwd.is_dir():
        raise SystemExit(f"working directory does not exist: {cwd}")
    if not assignment_source.is_file():
        raise SystemExit(f"assignment does not exist: {assignment_source}")

    run_dir = Path(tempfile.mkdtemp(prefix="estack-claude-", dir="/tmp"))
    assignment = run_dir / "assignment.md"
    stream = run_dir / "stream.jsonl"
    result = run_dir / "result.json"
    stderr = run_dir / "stderr.log"
    manifest_path = run_dir / "manifest.json"
    shutil.copyfile(assignment_source, assignment)

    manifest = {
        "run_directory": str(run_dir),
        "cwd": str(cwd),
        "model": args.model,
        "effort": args.effort,
        "pid": None,
        "started_at": utc_now(),
        "status": "starting",
        "session_id": None,
        "outputs": {
            "assignment": str(assignment),
            "stream": str(stream),
            "result": str(result),
            "stderr": str(stderr),
            "manifest": str(manifest_path),
        },
    }
    write_json(manifest_path, manifest)

    command = [
        args.claude_bin,
        "-p",
        "--model",
        args.model,
        "--effort",
        args.effort,
        "--permission-mode",
        args.permission_mode,
        "--tools",
        args.tools,
        "--output-format",
        "stream-json",
        "--verbose",
    ]
    if args.resume:
        command.extend(["--resume", args.resume])
    if not args.chrome:
        command.append("--no-chrome")
    if args.no_mcp:
        mcp_config = run_dir / "mcp.json"
        write_json(mcp_config, {"mcpServers": {}})
        command.extend(["--strict-mcp-config", "--mcp-config", str(mcp_config)])
    elif args.mcp_config:
        command.extend(
            ["--strict-mcp-config", "--mcp-config", str(args.mcp_config.resolve())]
        )

    final_event = None
    with (
        assignment.open("r", encoding="utf-8") as stdin_file,
        stream.open("w", encoding="utf-8") as stream_file,
        stderr.open("w", encoding="utf-8") as stderr_file,
    ):
        try:
            process = subprocess.Popen(
                command,
                cwd=cwd,
                stdin=stdin_file,
                stdout=subprocess.PIPE,
                stderr=stderr_file,
                text=True,
                bufsize=1,
            )
        except OSError as error:
            stderr_file.write(f"{error}\n")
            manifest["finished_at"] = utc_now()
            manifest["status"] = "failed"
            manifest["error"] = str(error)
            write_json(manifest_path, manifest)
            print_summary(
                {
                    "event": "finished",
                    "run_directory": str(run_dir),
                    "status": "failed",
                    "session_id": None,
                    "result": str(result),
                    "manifest": str(manifest_path),
                }
            )
            return 1
        manifest["pid"] = process.pid
        manifest["status"] = "running"
        write_json(manifest_path, manifest)
        print_summary(
            {
                "event": "started",
                "run_directory": str(run_dir),
                "pid": process.pid,
                "manifest": str(manifest_path),
            }
        )

        assert process.stdout is not None
        for line in process.stdout:
            stream_file.write(line)
            stream_file.flush()
            try:
                event = json.loads(line)
            except json.JSONDecodeError:
                continue
            if isinstance(event, dict) and event.get("type") == "result":
                final_event = event

        return_code = process.wait()

    if final_event is not None:
        write_json(result, final_event)
        session_id = final_event.get("session_id")
        if isinstance(session_id, str):
            manifest["session_id"] = session_id

    manifest["finished_at"] = utc_now()
    manifest["exit_code"] = return_code
    manifest["status"] = (
        "succeeded"
        if return_code == 0
        and final_event is not None
        and not final_event.get("is_error", False)
        else "failed"
    )
    write_json(manifest_path, manifest)
    print_summary(
        {
            "event": "finished",
            "run_directory": str(run_dir),
            "status": manifest["status"],
            "session_id": manifest["session_id"],
            "result": str(result),
            "manifest": str(manifest_path),
        }
    )
    return 0 if manifest["status"] == "succeeded" else return_code or 1


if __name__ == "__main__":
    raise SystemExit(main())
