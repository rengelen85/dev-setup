---
name: git-workflow
description: Git conventions for committing and branching. Use whenever creating a commit, creating or switching branches, pushing, or opening a pull request. Commits follow Conventional Commits and all work happens on a feature branch, never directly on main/master.
---

# Git workflow

## Branches

- Never commit or push directly to `main` or `master`. A PreToolUse hook blocks it.
- Before the first commit of a task, check the branch with `git branch --show-current`.
  If it's `main`/`master`, create a feature branch from an up-to-date default branch:
  ```bash
  git switch main && git pull --ff-only   # skip pull if there is no remote
  git switch -c <type>/<short-kebab-description>
  ```
- Branch names use the commit type as prefix: `feat/gh-skill`, `fix/go-path-macos`,
  `docs/readme-layout`, `chore/bump-deps`.
- Uncommitted changes made on `main` carry over with `git switch -c <branch>`; no stash needed.
- Push with `git push -u origin <branch>` and open a PR (`gh pr create`) to get changes into main.
- Exception: the very first commit in a freshly `git init`-ed repo may go on main.

## Conventional Commits

Format (https://www.conventionalcommits.org):

```
<type>(<optional scope>): <description>

<optional body: what and why, wrapped at 72 chars>

<optional footer(s)>
```

- **type**: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`,
  `chore`, `revert`.
- **scope**: the area touched, e.g. the role or module name: `feat(go): ...`.
- **description**: imperative mood, lowercase, no trailing period, max ~72 chars total
  header ("add uv role", not "Added uv role.").
- **Breaking changes**: add `!` after type/scope (`feat(api)!: ...`) and a
  `BREAKING CHANGE: <explanation>` footer.
- One logical change per commit. If a change needs two types, split it into two commits.
- Keep any required attribution trailers (e.g. `Co-Authored-By:`) as the last footer lines.

Use a heredoc so the body formats correctly:

```bash
git commit -F - <<'EOF'
feat(claude_code): add git-workflow skill

Install a skill for conventional commits and feature branches, plus a
hook that blocks commits and pushes to main.
EOF
```

PR titles follow the same `<type>(<scope>): <description>` format.
