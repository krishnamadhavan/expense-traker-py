from drf_spectacular.utils import extend_schema, extend_schema_view
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework_simplejwt.views import TokenObtainPairView

from .serializers import EmailOrUsernameTokenObtainPairSerializer


@extend_schema_view(
    post=extend_schema(
        tags=["auth"],
        summary="Obtain JWT access and refresh tokens",
        description=(
            "Authenticate with username **or** email in the `username` field, "
            "plus password. Returns `access` and `refresh` tokens."
        ),
    )
)
class EmailOrUsernameTokenObtainPairView(TokenObtainPairView):
    serializer_class = EmailOrUsernameTokenObtainPairSerializer


@extend_schema(
    tags=["auth"],
    summary="Current user profile",
    responses={
        200: {
            "type": "object",
            "properties": {
                "id": {"type": "integer"},
                "username": {"type": "string"},
                "email": {"type": "string", "format": "email"},
            },
        }
    },
)
@api_view(["GET"])
@permission_classes([IsAuthenticated])
def me(request):
    """Return the authenticated user's profile (protected sample endpoint)."""
    user = request.user
    return Response(
        {
            "id": user.pk,
            "username": user.get_username(),
            "email": user.email,
        }
    )
