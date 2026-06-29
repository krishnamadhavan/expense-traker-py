# Expense Tracker

API-first web application for tracking personal expenses.

## Stack

- **Backend:** Python, Django, Django REST Framework (`backend/`)
- **Frontend:** React (planned under `frontend/`)
- **Repository:** GitHub

## Approach

Built step by step, API first.

## Backend (local)

```bash
cd backend
python3 -m venv ../.venv   # or reuse repo-root .venv
source ../.venv/bin/activate
pip install -r requirements.txt
cp .env.example .env       # set DJANGO_SECRET_KEY at minimum
python manage.py migrate
python manage.py runserver
```

- Liveness: `GET /health/`
- Readiness: `GET /ready/`

Settings modules: `config.settings.local` (default for `manage.py`) and `config.settings.production` (WSGI/Gunicorn/Docker).

## Backend (production-style)

```bash
cd backend
# set required env vars (see .env.example)
gunicorn --config gunicorn.conf.py config.wsgi:application
# or
docker compose up --build
```
