from django.urls import reverse
from rest_framework import status
from rest_framework.test import APITestCase


class HealthEndpointTests(APITestCase):
    def test_health_get_returns_ok(self):
        response = self.client.get(reverse("health"))

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.json(), {"status": "ok"})

    def test_health_rejects_post(self):
        response = self.client.post(reverse("health"))

        self.assertEqual(response.status_code, status.HTTP_405_METHOD_NOT_ALLOWED)
