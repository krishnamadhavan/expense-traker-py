from django.db import connection
from rest_framework import status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import AllowAny
from rest_framework.response import Response


@api_view(["GET"])
@permission_classes([AllowAny])
def health(request):
    """Liveness: process is up and serving requests."""
    return Response({"status": "ok"})


@api_view(["GET"])
@permission_classes([AllowAny])
def ready(request):
    """Readiness: app can serve traffic (e.g. database is reachable)."""
    try:
        connection.ensure_connection()
    except Exception as exc:
        return Response(
            {"status": "unavailable", "detail": str(exc)},
            status=status.HTTP_503_SERVICE_UNAVAILABLE,
        )
    return Response({"status": "ready"})
