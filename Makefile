SHELL_SCRIPTS := $(shell find . -name '*.sh' -not -path './.git/*' -not -path './claude/skills/synced/*')
PYTHON_DIR := claude/hooks

.PHONY: lint format test

lint:
	shellcheck $(SHELL_SCRIPTS)
	shfmt --diff $(SHELL_SCRIPTS)
	uvx ruff@latest check $(PYTHON_DIR)
	uvx ruff@latest format --check $(PYTHON_DIR)

format:
	shfmt --write $(SHELL_SCRIPTS)
	uvx ruff@latest check --fix $(PYTHON_DIR)
	uvx ruff@latest format $(PYTHON_DIR)

test:
	/usr/bin/python3 -B -m unittest discover -s $(PYTHON_DIR) -p '*_test.py'
