#!/usr/bin/env bash
# Bootstrap a dev workstation: install just enough (git, curl, make, Ansible)
# to hand over to `make install`, which configures everything else.
#
# Usage: ./install.sh [tool...]    e.g. ./install.sh go uv   (default: all)
#   tools: gh, uv, go, node, docker, mkcert, aws, android, claude_code
#
# Supports Debian/Ubuntu (incl. WSL), Fedora/RHEL, and macOS (via Homebrew).
# Safe to re-run.
set -euo pipefail

log() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
die() { printf '\033[1;31mxx\033[0m %s\n' "$*" >&2; exit 1; }
have() { command -v "$1" >/dev/null 2>&1; }

# Run as root when needed; no-op wrapper if we already are root.
sudo_() { if [ "$(id -u)" -eq 0 ]; then "$@"; else sudo "$@"; fi; }

case "${1:-}" in
  -h|--help) sed -n '2,/^[^#]/{/^#/s/^# \{0,1\}//p}' "$0"; exit 0 ;;
esac

cd "$(dirname "$0")"

missing=()
for cmd in git curl make ansible-playbook; do have "$cmd" || missing+=("$cmd"); done

if [ ${#missing[@]} -gt 0 ]; then
  log "Installing bootstrap dependencies: ${missing[*]}"
  case "$(uname -s)" in
    Darwin)
      have brew || die "Install Homebrew first: https://brew.sh"
      # Xcode Command Line Tools provide git and make.
      have make || xcode-select --install || true
      brew install ansible ;;
    Linux)
      if have apt-get; then
        sudo_ apt-get update -qq
        sudo_ apt-get install -y git curl make ansible ca-certificates
      elif have dnf; then
        sudo_ dnf install -y git curl make ansible
      else
        die "Unsupported Linux distro (need apt or dnf)"
      fi ;;
    *) die "Unsupported OS: $(uname -s)" ;;
  esac
fi

tags="$(IFS=,; echo "$*")"
log "Handing over to: make install${tags:+ TAGS=$tags}"
exec make install ${tags:+TAGS="$tags"}
