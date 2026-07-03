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
- Obtain tokens: `POST /api/auth/token/`
- Refresh access: `POST /api/auth/token/refresh/` body `{"refresh": "..."}`

Login accepts **username or email** in the `username` field (SimpleJWT shape):

```json
{"username": "alice", "password": "..."}
{"username": "alice@example.com", "password": "..."}
```

### API documentation (Swagger / OpenAPI)

Interactive docs (public; use **Authorize** in Swagger UI with a Bearer access token for protected routes):

- Swagger UI: http://127.0.0.1:8000/api/docs/
- ReDoc: http://127.0.0.1:8000/api/redoc/
- OpenAPI schema: http://127.0.0.1:8000/api/schema/

### Protected endpoints

All other API routes require:

```http
Authorization: Bearer <access_token>
```

Example: `GET /api/auth/me/` returns the current user (`id`, `username`, `email`).

### Create a user (no public registration)

Uses Django’s default user model (`username` + `email` + password). Create accounts with management commands after migrate:

```bash
# Interactive (username, email optional, password)
cd backend && python manage.py createsuperuser

# Or non-interactive from the project root (venv activated)
python backend/manage.py shell <<'PY'
from django.contrib.auth import get_user_model
User = get_user_model()
User.objects.create_user(
    username="alice",
    email="alice@example.com",
    password="choose-a-strong-password",
)
PY
```

Then obtain tokens:

```bash
curl -s -X POST http://127.0.0.1:8000/api/auth/token/ \
  -H 'Content-Type: application/json' \
  -d '{"username":"alice","password":"choose-a-strong-password"}'
# or: "username":"alice@example.com"
```

Settings modules: `config.settings.local` (default for `manage.py`) and `config.settings.production` (WSGI/Gunicorn/Docker).

Database connection uses discrete env vars: `POSTGRES_HOST`, `POSTGRES_PORT`, `POSTGRES_DB`, `POSTGRES_USER`, `POSTGRES_PASSWORD` (see `backend/.env.example`).

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
