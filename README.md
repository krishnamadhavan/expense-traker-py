# Expense Tracker

API-first web application for tracking personal expenses.

## Stack

- **Backend:** Python, Django, Django REST Framework, PostgreSQL (`backend/`)
- **Frontend:** React (planned under `frontend/`)
- **Repository:** GitHub

## Approach

Built step by step, API first.

## Backend (local)

PostgreSQL runs in Docker Compose; the API runs on the host by default.

```bash
make install
make env
make pre-commit-install
make db-up
make migrate
make run
```

- Liveness: `GET /health/`
- Readiness: `GET /ready/`

Settings modules: `config.settings.local` (default for `manage.py`) and `config.settings.production` (WSGI/Gunicorn/Docker).

Database connection uses discrete env vars: `POSTGRES_HOST`, `POSTGRES_PORT`, `POSTGRES_DB`, `POSTGRES_USER`, `POSTGRES_PASSWORD` (see `backend/.env.example`).

### Quality hooks

```bash
make pre-commit-install   # once per clone
make pre-commit-run       # run all hooks
```

## Backend (production-style)

```bash
make docker-up   # API + PostgreSQL via Compose / Gunicorn
```
