from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response


@api_view(["GET"])
@permission_classes([IsAuthenticated])
def me(request):
    """Return the authenticated user's profile (protected sample endpoint)."""
    user = request.user
    return Response(
        {
            "id": user.pk,
            "email": user.email,
        }
    )
