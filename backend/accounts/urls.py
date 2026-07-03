from django.urls import path
from drf_spectacular.utils import extend_schema, extend_schema_view
from rest_framework_simplejwt.views import TokenRefreshView

from . import views


@extend_schema_view(
    post=extend_schema(
        tags=["auth"],
        summary="Refresh JWT access token",
    )
)
class TaggedTokenRefreshView(TokenRefreshView):
    pass


urlpatterns = [
    path(
        "token/",
        views.EmailOrUsernameTokenObtainPairView.as_view(),
        name="token_obtain_pair",
    ),
    path("token/refresh/", TaggedTokenRefreshView.as_view(), name="token_refresh"),
    path("me/", views.me, name="me"),
]
