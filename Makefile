# Common commands for the backend (Django).
# Run from the repository root: `make <target>`
# Type `make help` for the full list.

.DEFAULT_GOAL := help

ROOT        := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
BACKEND_DIR := $(ROOT)/backend
COMPOSE     := docker compose -f $(BACKEND_DIR)/docker-compose.yml

# Virtualenv at repo root (create with `make backend-venv`)
VENV        := $(ROOT)/.venv
PYTHON      := $(VENV)/bin/python
PIP         := $(VENV)/bin/pip
PRE_COMMIT  := $(VENV)/bin/pre-commit
MANAGE      := $(PYTHON) $(BACKEND_DIR)/manage.py

.PHONY: help \
	backend-venv backend-install backend-env \
	makemigrations migrate check check-deploy shell collectstatic \
	gunicorn docker-build docker-up docker-down \
	pre-commit-install pre-commit-run test

help: ## Show available targets
	@echo "Expense Tracker — Make targets"
	@echo ""
	@echo "Setup"
	@grep -E '^(backend-venv|backend-install|backend-env|pre-commit-install):.*?##' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-24s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "Backend"
	@grep -E '^(makemigrations|migrate|run|check|check-deploy|shell|collectstatic|gunicorn|db-up|db-down|docker-build|docker-up|docker-down|test):.*?##' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-24s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "Quality"
	@grep -E '^pre-commit-[a-zA-Z0-9_-]+:.*?##' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-24s\033[0m %s\n", $$1, $$2}'

# ---------------------------------------------------------------------------
# Backend
# ---------------------------------------------------------------------------

backend-venv: ## Create Python virtualenv at .venv
	python3 -m venv $(VENV)
	$(PIP) install --upgrade pip

backend-install: backend-venv ## Install backend Python dependencies (local)
	$(PIP) install -r $(BACKEND_DIR)/requirements/local.txt

backend-env: ## Copy backend/.env.example -> backend/.env if missing
	@if [ ! -f $(BACKEND_DIR)/.env ]; then \
		cp $(BACKEND_DIR)/.env.example $(BACKEND_DIR)/.env; \
		echo "Created $(BACKEND_DIR)/.env — edit DJANGO_SECRET_KEY and other values."; \
	else \
		echo "$(BACKEND_DIR)/.env already exists; leaving it unchanged."; \
	fi

makemigrations: ## Create Django migrations from model changes
	$(MANAGE) makemigrations

migrate: ## Apply Django migrations
	$(MANAGE) migrate

check: ## Django system checks (local settings)
	$(MANAGE) check

check-deploy: ## Django deploy checks (production settings)
	cd $(BACKEND_DIR) && \
		DJANGO_SETTINGS_MODULE=config.settings.production \
		$(PYTHON) manage.py check --deploy

shell: ## Open Django shell
	$(MANAGE) shell

collectstatic: ## Collect static files
	$(MANAGE) collectstatic --noinput

gunicorn: ## Run API with Gunicorn (production-style)
	cd $(BACKEND_DIR) && $(VENV)/bin/gunicorn --config gunicorn.conf.py config.wsgi:application

docker-build: ## Build backend Docker image
	$(COMPOSE) build

docker-up: ## Start API + PostgreSQL via Docker Compose
	$(COMPOSE) up -d --build

docker-down: ## Stop all backend Compose services
	$(COMPOSE) down

# ---------------------------------------------------------------------------
# pre-commit (tools run in pre-commit's own environments)
# ---------------------------------------------------------------------------

pre-commit-install: backend-install ## Install git hooks (pre-commit + commit-msg)
	$(PRE_COMMIT) install --install-hooks

pre-commit-run: ## Run all pre-commit hooks on the repo
	$(PRE_COMMIT) run --all-files

test: ## Run the Django unit test suite
	cd $(BACKEND_DIR) && $(PYTHON) manage.py test --verbosity=1
