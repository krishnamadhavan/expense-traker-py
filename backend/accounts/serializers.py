from django.contrib.auth import get_user_model
from django.db.models import Q
from rest_framework import serializers
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer

User = get_user_model()


class EmailOrUsernameTokenObtainPairSerializer(TokenObtainPairSerializer):
    """
    Obtain tokens with either username or email as the login identifier.

    Clients send the standard SimpleJWT shape using the ``username`` field for
    either a username or an email address, for example::

        {"username": "alice", "password": "..."}
        {"username": "alice@example.com", "password": "..."}
    """

    def validate(self, attrs):
        login = attrs.get(self.username_field)
        if not login:
            raise serializers.ValidationError(
                {self.username_field: "This field is required."},
                code="required",
            )

        user = (
            User.objects.filter(Q(username__iexact=login) | Q(email__iexact=login))
            .order_by("id")
            .first()
        )
        if user is None:
            # Let the parent path produce the same error shape as a bad password.
            return super().validate(attrs)

        # Authenticate against the real USERNAME_FIELD (username on default User).
        attrs[self.username_field] = user.get_username()
        return super().validate(attrs)
