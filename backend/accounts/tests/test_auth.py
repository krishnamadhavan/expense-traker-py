from django.urls import reverse
from rest_framework import status
from rest_framework.test import APITestCase

from accounts.models import User


class AuthEndpointTests(APITestCase):
    def setUp(self):
        self.user = User.objects.create_user(
            email="user@example.com",
            password="secure-pass-123",
        )

    def test_token_obtain_returns_access_and_refresh(self):
        response = self.client.post(
            reverse("token_obtain_pair"),
            {"email": "user@example.com", "password": "secure-pass-123"},
            format="json",
        )

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn("access", response.json())
        self.assertIn("refresh", response.json())

    def test_token_obtain_rejects_bad_credentials(self):
        response = self.client.post(
            reverse("token_obtain_pair"),
            {"email": "user@example.com", "password": "wrong"},
            format="json",
        )

        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)

    def test_token_refresh_returns_new_access(self):
        obtain = self.client.post(
            reverse("token_obtain_pair"),
            {"email": "user@example.com", "password": "secure-pass-123"},
            format="json",
        )
        refresh = obtain.json()["refresh"]

        response = self.client.post(
            reverse("token_refresh"),
            {"refresh": refresh},
            format="json",
        )

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn("access", response.json())

    def test_me_requires_authentication(self):
        response = self.client.get(reverse("me"))

        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)

    def test_me_returns_user_with_valid_token(self):
        obtain = self.client.post(
            reverse("token_obtain_pair"),
            {"email": "user@example.com", "password": "secure-pass-123"},
            format="json",
        )
        access = obtain.json()["access"]

        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {access}")
        response = self.client.get(reverse("me"))

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(
            response.json(),
            {"id": self.user.pk, "email": "user@example.com"},
        )
