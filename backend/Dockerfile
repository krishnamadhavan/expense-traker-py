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

RUN mkdir -p /app/data /app/staticfiles && chown -R app:app /app

# Collect static at build time (build-arg secrets are not runtime secrets)
ARG DJANGO_SECRET_KEY=build-time-only-not-for-runtime
ARG DJANGO_ALLOWED_HOSTS=localhost
ARG CSRF_TRUSTED_ORIGINS=https://localhost
ENV DJANGO_SECRET_KEY=${DJANGO_SECRET_KEY} \
    DJANGO_ALLOWED_HOSTS=${DJANGO_ALLOWED_HOSTS} \
    CSRF_TRUSTED_ORIGINS=${CSRF_TRUSTED_ORIGINS} \
    DJANGO_SECURE_SSL_REDIRECT=false

RUN python manage.py collectstatic --noinput \
    && chown -R app:app /app

USER app

EXPOSE 8000

CMD ["gunicorn", "--config", "gunicorn.conf.py", "config.wsgi:application"]
