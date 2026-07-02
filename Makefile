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
	backend-venv backend-install backend-env backend-migrate backend-makemigrations \
	backend-run backend-check backend-check-deploy backend-shell backend-collectstatic \
	backend-gunicorn backend-docker-up backend-docker-down backend-docker-build \
	backend-db-up backend-db-down \
	pre-commit-install pre-commit-run \
	install setup migrate run run-backend \
	docker-up docker-down db-up db-down check

help: ## Show available targets
	@echo "Expense Tracker — Make targets"
	@echo ""
	@echo "Setup"
	@grep -E '^(backend-venv|backend-install|backend-env|pre-commit-install|install|setup):.*?##' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-24s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "Backend"
	@grep -E '^backend-[a-zA-Z0-9_-]+:.*?##' $(MAKEFILE_LIST) | \
		grep -vE 'backend-(venv|install|env):' | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-24s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "Quality"
	@grep -E '^pre-commit-[a-zA-Z0-9_-]+:.*?##' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-24s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "Shortcuts"
	@grep -E '^(install|setup|migrate|run|run-backend|docker-up|docker-down|db-up|db-down|check):.*?##' $(MAKEFILE_LIST) | \
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

backend-makemigrations: ## Create Django migrations from model changes
	$(MANAGE) makemigrations

backend-migrate: ## Apply Django migrations
	$(MANAGE) migrate

backend-run: ## Run Django development server (requires make db-up)
	$(MANAGE) runserver

backend-check: ## Django system checks (local settings)
	$(MANAGE) check

backend-check-deploy: ## Django deploy checks (production settings)
	cd $(BACKEND_DIR) && \
		DJANGO_SETTINGS_MODULE=config.settings.production \
		$(PYTHON) manage.py check --deploy

backend-shell: ## Open Django shell
	$(MANAGE) shell

backend-collectstatic: ## Collect static files
	$(MANAGE) collectstatic --noinput

backend-gunicorn: ## Run API with Gunicorn (production-style)
	cd $(BACKEND_DIR) && $(VENV)/bin/gunicorn --config gunicorn.conf.py config.wsgi:application

backend-db-up: ## Start PostgreSQL via Docker Compose
	$(COMPOSE) up -d db

backend-db-down: ## Stop PostgreSQL Compose service
	$(COMPOSE) stop db

backend-docker-build: ## Build backend Docker image
	$(COMPOSE) build

backend-docker-up: ## Start API + PostgreSQL via Docker Compose
	$(COMPOSE) up --build

backend-docker-down: ## Stop all backend Compose services
	$(COMPOSE) down

# ---------------------------------------------------------------------------
# pre-commit (tools run in pre-commit's own environments)
# ---------------------------------------------------------------------------

pre-commit-install: backend-install ## Install git hooks (pre-commit + commit-msg)
	$(PRE_COMMIT) install --install-hooks

pre-commit-run: ## Run all pre-commit hooks on the repo
	$(PRE_COMMIT) run --all-files

# ---------------------------------------------------------------------------
# Shortcuts
# ---------------------------------------------------------------------------

install: backend-install ## Install backend dependencies

setup: install backend-env pre-commit-install backend-db-up backend-migrate ## Full local setup

migrate: backend-migrate ## Alias for backend-migrate

run: backend-run ## Alias for backend-run

run-backend: backend-run ## Alias for backend-run

docker-up: backend-docker-up ## Alias for backend-docker-up

docker-down: backend-docker-down ## Alias for backend-docker-down

db-up: backend-db-up ## Alias for backend-db-up

db-down: backend-db-down ## Alias for backend-db-down

check: backend-check ## Alias for backend-check
