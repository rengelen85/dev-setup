.DEFAULT_GOAL := help
.PHONY: help install deps playbook auth check lint

# Limit to some tools: make install TAGS=go,uv
TAGS ?=
# Prompts for the sudo password; set empty with passwordless sudo: make install BECOME=
BECOME ?= --ask-become-pass
# Extra ansible-playbook arguments, e.g. ARGS="-e go_version=1.25.3 -v"
ARGS ?=

# Ubuntu 25.10+ defaults to sudo-rs, which rewrites the password prompt Ansible
# waits for (-> "Timed out waiting for become ... password prompt"). Use the
# original sudo, shipped alongside as sudo.ws, when it's available.
SUDO_WS := $(shell command -v sudo.ws 2>/dev/null)

PLAYBOOK = ansible-playbook site.yml $(BECOME) $(if $(TAGS),--tags $(TAGS)) \
	$(if $(SUDO_WS),-e ansible_become_exe=$(SUDO_WS)) $(ARGS)

help: ## Show available targets
	@grep -E '^[a-z-]+:.*## ' $(MAKEFILE_LIST) | awk -F':.*## ' '{printf "  %-10s %s\n", $$1, $$2}'

install: deps playbook auth ## Install and configure everything

deps: ## Install required Ansible collections
	ansible-galaxy collection install -r requirements.yml

playbook:
	$(PLAYBOOK)

# Interactive, so it lives here rather than in the playbook.
auth: ## Log in to GitHub with gh (skipped when already logged in)
	@if ! command -v gh >/dev/null; then echo "gh not installed, skipping auth"; \
	elif gh auth status >/dev/null 2>&1; then echo "gh already authenticated"; \
	else gh auth login && gh auth setup-git; fi

check: deps ## Dry run: show what would change
	$(PLAYBOOK) --check --diff

lint: ## Syntax-check the playbook
	ansible-playbook site.yml --syntax-check
