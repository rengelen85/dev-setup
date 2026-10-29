# dev-setup

Bootstrap a new dev machine with:

- **[gh](https://cli.github.com/)**: GitHub CLI. It's installed, logged in, and set up as git's credential helper.
- **[uv](https://docs.astral.sh/uv/)**: Python package and project manager.
- **[Go](https://go.dev/)**: latest stable release, from the official tarball.
- **[Claude Code](https://docs.claude.com/en/docs/claude-code/setup)**: installed with the native installer.

Works on Debian/Ubuntu (including WSL), Fedora/RHEL, and macOS (requires Homebrew).

## Usage

```bash
git clone <this repo> && cd dev-setup
./install.sh              # everything
./install.sh go uv        # just some tools
```

`install.sh` only installs the bootstrap tools (git, curl, make, Ansible) and then
runs `make install`. Everything else is an Ansible playbook, so once Ansible is installed
you can use make directly:

```bash
make install                         # deps + playbook + gh login
make install TAGS=go,claude_code     # subset
make check                           # dry run with diff
make install ARGS="-e go_version=1.25.3"
make install BECOME=                 # passwordless sudo: no password prompt
```

Re-running is safe: tools are updated to their latest version, and nothing else changes.

## Layout

```
install.sh        bootstrap → make install
Makefile          install / check / lint / auth targets
site.yml          playbook and its settings (go_version, go_prefix, PATH entries)
roles/<tool>/     one role per tool; role name = tag
roles/shell_path  managed PATH block in ~/.bashrc and ~/.zshrc
```

To add a tool, create `roles/<name>/tasks/main.yml` and add it to `site.yml` with a
matching tag.
