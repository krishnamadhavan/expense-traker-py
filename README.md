# Expense Tracker

API-first web application for tracking personal expenses.

## Stack

- **Backend:** Python, Django, Django REST Framework, PostgreSQL, JWT (`backend/`)
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

### Public endpoints (no auth)

- Liveness: `GET /health/`
- Readiness: `GET /ready/`
- Obtain tokens: `POST /api/auth/token/` body `{"email": "...", "password": "..."}`
- Refresh access: `POST /api/auth/token/refresh/` body `{"refresh": "..."}`

### Protected endpoints

All other API routes require:

```http
Authorization: Bearer <access_token>
```

Example: `GET /api/auth/me/` returns the current user.

### Create a user (no public registration)

There is no sign-up API. Create accounts with Django management commands after migrate:

```bash
# Interactive (prompts for email and password)
cd backend && python manage.py createsuperuser

# Or non-interactive from the project root (venv activated)
python backend/manage.py shell <<'PY'
from accounts.models import User
User.objects.create_user(email="you@example.com", password="choose-a-strong-password")
PY
```

Then obtain tokens:

```bash
curl -s -X POST http://127.0.0.1:8000/api/auth/token/ \
  -H 'Content-Type: application/json' \
  -d '{"email":"you@example.com","password":"choose-a-strong-password"}'
```

Settings modules: `config.settings.local` (default for `manage.py`) and `config.settings.production` (WSGI/Gunicorn/Docker).

Database connection uses discrete env vars: `POSTGRES_HOST`, `POSTGRES_PORT`, `POSTGRES_DB`, `POSTGRES_USER`, `POSTGRES_PASSWORD` (see `backend/.env.example`).

**Note:** Switching to the email-based custom user model requires a database that has not already applied the default `auth.User` schema. For local Compose Postgres, reset if migrate fails after pull:

```bash
make docker-down
docker volume rm backend_postgres_data   # name may vary; see `docker volume ls`
make db-up
make migrate
```

### Quality hooks

```bash
make pre-commit-install   # once per clone
make pre-commit-run       # run all hooks
make test                 # unit tests
```

## Backend (production-style)

```bash
make docker-up   # API + PostgreSQL via Compose / Gunicorn
```
