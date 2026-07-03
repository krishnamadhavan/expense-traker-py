from django.contrib.auth import get_user_model
from django.urls import reverse
from rest_framework import status
from rest_framework.test import APITestCase

User = get_user_model()


class AuthEndpointTests(APITestCase):
    def setUp(self):
        self.user = User.objects.create_user(
            username="alice",
            email="alice@example.com",
            password="secure-pass-123",
        )

    def test_token_obtain_with_username(self):
        response = self.client.post(
            reverse("token_obtain_pair"),
            {"username": "alice", "password": "secure-pass-123"},
            format="json",
        )

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn("access", response.json())
        self.assertIn("refresh", response.json())

    def test_token_obtain_with_email(self):
        response = self.client.post(
            reverse("token_obtain_pair"),
            {"username": "alice@example.com", "password": "secure-pass-123"},
            format="json",
        )

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn("access", response.json())
        self.assertIn("refresh", response.json())

    def test_token_obtain_rejects_bad_credentials(self):
        response = self.client.post(
            reverse("token_obtain_pair"),
            {"username": "alice", "password": "wrong"},
            format="json",
        )

        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)

    def test_token_refresh_returns_new_access(self):
        obtain = self.client.post(
            reverse("token_obtain_pair"),
            {"username": "alice", "password": "secure-pass-123"},
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
            {"username": "alice@example.com", "password": "secure-pass-123"},
            format="json",
        )
        access = obtain.json()["access"]

        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {access}")
        response = self.client.get(reverse("me"))

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(
            response.json(),
            {
                "id": self.user.pk,
                "username": "alice",
                "email": "alice@example.com",
            },
        )
