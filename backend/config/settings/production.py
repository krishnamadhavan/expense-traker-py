"""Production settings. Requires env vars; fails closed on misconfiguration."""

from .base import *  # noqa: F403
from .base import SECRET_KEY, env_bool, env_list

DEBUG = False

if not SECRET_KEY or SECRET_KEY.startswith("django-insecure-"):
    raise ValueError("Production requires a strong DJANGO_SECRET_KEY")

ALLOWED_HOSTS = env_list("DJANGO_ALLOWED_HOSTS")
if not ALLOWED_HOSTS:
    raise ValueError("DJANGO_ALLOWED_HOSTS must be set in production")

# HTTPS / cookie hardening (enable when serving behind TLS termination)
SECURE_SSL_REDIRECT = env_bool("DJANGO_SECURE_SSL_REDIRECT", default=True)
SESSION_COOKIE_SECURE = True
CSRF_COOKIE_SECURE = True
SECURE_BROWSER_XSS_FILTER = True
SECURE_CONTENT_TYPE_NOSNIFF = True
X_FRAME_OPTIONS = "DENY"
SECURE_HSTS_SECONDS = int(
    __import__("os").environ.get("DJANGO_SECURE_HSTS_SECONDS", "31536000")
)
SECURE_HSTS_INCLUDE_SUBDOMAINS = env_bool(
    "DJANGO_SECURE_HSTS_INCLUDE_SUBDOMAINS", default=True
)
SECURE_HSTS_PRELOAD = env_bool("DJANGO_SECURE_HSTS_PRELOAD", default=True)
SECURE_PROXY_SSL_HEADER = ("HTTP_X_FORWARDED_PROTO", "https")

# Prefer explicit CSRF trusted origins in production
if not CSRF_TRUSTED_ORIGINS:  # noqa: F405
    raise ValueError("CSRF_TRUSTED_ORIGINS must be set in production")
