from django.urls import path

from . import views

urlpatterns = [
    path(
        "token/",
        views.EmailOrUsernameTokenObtainPairView.as_view(),
        name="token_obtain_pair",
    ),
    path(
        "token/refresh/",
        views.TaggedTokenRefreshView.as_view(),
        name="token_refresh",
    ),
    path("me/", views.me, name="me"),
]
