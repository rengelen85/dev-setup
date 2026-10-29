#!/usr/bin/env python3
"""Claude Code PreToolUse hook: block `git commit` and `git push` on main/master.

Exit code 2 blocks the tool call and shows stderr to Claude.
"""
import json
import os
import re
import subprocess
import sys

PROTECTED = {"main", "master"}
# `git [-C dir | -c k=v ...] commit|push ...`, anywhere in a compound command.
GIT_CMD = re.compile(
    r"(?:^|[;&|(]|\s)git((?:\s+-[Cc]\s+\S+)*)\s+(commit|push)\b([^;&|]*)"
)


def git(cwd, *args):
    result = subprocess.run(
        ["git", "-C", cwd, *args], capture_output=True, text=True
    )
    return result.stdout.strip() if result.returncode == 0 else None


def main():
    data = json.load(sys.stdin)
    command = data.get("tool_input", {}).get("command", "")
    base = data.get("cwd") or os.getcwd()

    for match in GIT_CMD.finditer(command):
        opts, action, rest = match.groups()
        cwd = base
        dirs = re.findall(r"-C\s+(\S+)", opts)
        if dirs:
            cwd = os.path.join(base, os.path.expanduser(dirs[-1].strip("'\"")))

        branch = git(cwd, "branch", "--show-current")
        if action == "commit":
            # Allow the initial commit of a new repo.
            if branch in PROTECTED and git(cwd, "rev-parse", "--verify", "HEAD"):
                block(f"Committing directly to '{branch}' is not allowed.")
        else:
            refs = {r.split(":")[-1].removeprefix("refs/heads/") for r in rest.split()}
            refs = {branch if r == "HEAD" else r for r in refs}
            if refs & PROTECTED or (branch in PROTECTED and len(rest.split()) <= 1):
                block("Pushing to main/master is not allowed.")
    sys.exit(0)


def block(reason):
    print(
        f"{reason} Create a feature branch first "
        "(git switch -c <type>/<description>) and open a PR.",
        file=sys.stderr,
    )
    sys.exit(2)


if __name__ == "__main__":
    main()
