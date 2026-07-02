from unittest.mock import patch

from django.db import OperationalError
from django.urls import reverse
from rest_framework import status
from rest_framework.test import APITestCase


class ReadyEndpointTests(APITestCase):
    def test_ready_get_returns_ready_when_database_is_up(self):
        response = self.client.get(reverse("ready"))

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.json(), {"status": "ready"})

    def test_ready_returns_503_when_database_is_unavailable(self):
        with patch(
            "core.views.connection.ensure_connection",
            side_effect=OperationalError("could not connect to server"),
        ):
            response = self.client.get(reverse("ready"))

        self.assertEqual(response.status_code, status.HTTP_503_SERVICE_UNAVAILABLE)
        body = response.json()
        self.assertEqual(body["status"], "unavailable")
        self.assertIn("could not connect to server", body["detail"])

    def test_ready_rejects_post(self):
        response = self.client.post(reverse("ready"))

        self.assertEqual(response.status_code, status.HTTP_405_METHOD_NOT_ALLOWED)
