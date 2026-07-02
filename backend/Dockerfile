# Production-oriented image for the Django API
FROM python:3.14-slim AS base

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    DJANGO_SETTINGS_MODULE=config.settings.production

WORKDIR /app

RUN addgroup --system app && adduser --system --ingroup app app

COPY requirements/ requirements/
RUN pip install --upgrade pip && pip install -r requirements/production.txt

COPY --chown=app:app . .

RUN mkdir -p /app/staticfiles && chown -R app:app /app

# collectstatic loads settings; provide non-secret build-time placeholders
ARG DJANGO_SECRET_KEY=build-time-only-not-for-runtime
ARG DJANGO_ALLOWED_HOSTS=localhost
ARG CSRF_TRUSTED_ORIGINS=https://localhost
ARG POSTGRES_DB=build
ARG POSTGRES_USER=build
ARG POSTGRES_PASSWORD=build
ARG POSTGRES_HOST=localhost
ENV DJANGO_SECRET_KEY=${DJANGO_SECRET_KEY} \
    DJANGO_ALLOWED_HOSTS=${DJANGO_ALLOWED_HOSTS} \
    CSRF_TRUSTED_ORIGINS=${CSRF_TRUSTED_ORIGINS} \
    DJANGO_SECURE_SSL_REDIRECT=false \
    POSTGRES_DB=${POSTGRES_DB} \
    POSTGRES_USER=${POSTGRES_USER} \
    POSTGRES_PASSWORD=${POSTGRES_PASSWORD} \
    POSTGRES_HOST=${POSTGRES_HOST}

RUN python manage.py collectstatic --noinput \
    && chown -R app:app /app

USER app

EXPOSE 8000

CMD ["gunicorn", "--config", "gunicorn.conf.py", "config.wsgi:application"]
