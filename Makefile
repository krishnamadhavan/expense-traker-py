# Common commands for the backend (Django).
# Run from the repository root: `make <target>`
# Type `make help` for the full list.

.DEFAULT_GOAL := help

ROOT        := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
BACKEND_DIR := $(ROOT)/backend

# Virtualenv at repo root (create with `make backend-venv`)
VENV        := $(ROOT)/.venv
PYTHON      := $(VENV)/bin/python
PIP         := $(VENV)/bin/pip
MANAGE      := $(PYTHON) $(BACKEND_DIR)/manage.py

.PHONY: help \
	backend-venv backend-install backend-env backend-migrate backend-run \
	backend-check backend-check-deploy backend-shell backend-collectstatic \
	backend-gunicorn backend-docker-up backend-docker-down backend-docker-build \
	install setup migrate run run-backend \
	docker-up docker-down check

help: ## Show available targets
	@echo "Expense Tracker — Make targets"
	@echo ""
	@echo "Setup"
	@grep -E '^(backend-venv|backend-install|backend-env|install|setup):.*?##' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-22s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "Backend"
	@grep -E '^backend-[a-zA-Z0-9_-]+:.*?##' $(MAKEFILE_LIST) | \
		grep -vE 'backend-(venv|install|env):' | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-22s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "Shortcuts"
	@grep -E '^(install|setup|migrate|run|run-backend|docker-up|docker-down|check):.*?##' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-22s\033[0m %s\n", $$1, $$2}'

# ---------------------------------------------------------------------------
# Backend
# ---------------------------------------------------------------------------

backend-venv: ## Create Python virtualenv at .venv
	python3 -m venv $(VENV)
	$(PIP) install --upgrade pip

backend-install: backend-venv ## Install backend Python dependencies
	$(PIP) install -r $(BACKEND_DIR)/requirements.txt

backend-env: ## Copy backend/.env.example -> backend/.env if missing
	@if [ ! -f $(BACKEND_DIR)/.env ]; then \
		cp $(BACKEND_DIR)/.env.example $(BACKEND_DIR)/.env; \
		echo "Created $(BACKEND_DIR)/.env — edit DJANGO_SECRET_KEY and other values."; \
	else \
		echo "$(BACKEND_DIR)/.env already exists; leaving it unchanged."; \
	fi

backend-migrate: ## Apply Django migrations
	$(MANAGE) migrate

backend-run: ## Run Django development server
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

backend-docker-build: ## Build backend Docker image
	docker compose -f $(BACKEND_DIR)/docker-compose.yml build

backend-docker-up: ## Start backend via Docker Compose
	docker compose -f $(BACKEND_DIR)/docker-compose.yml up --build

backend-docker-down: ## Stop backend Docker Compose services
	docker compose -f $(BACKEND_DIR)/docker-compose.yml down

# ---------------------------------------------------------------------------
# Shortcuts
# ---------------------------------------------------------------------------

install: backend-install ## Install backend dependencies

setup: install backend-env backend-migrate ## Full local setup (venv, deps, .env, migrate)

migrate: backend-migrate ## Alias for backend-migrate

run: backend-run ## Alias for backend-run

run-backend: backend-run ## Alias for backend-run

docker-up: backend-docker-up ## Alias for backend-docker-up

docker-down: backend-docker-down ## Alias for backend-docker-down

check: backend-check ## Alias for backend-check
