from django.urls import reverse
from rest_framework import status
from rest_framework.test import APITestCase


class OpenAPISchemaTests(APITestCase):
    def test_schema_is_public(self):
        response = self.client.get(reverse("schema"))

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn("openapi", response.data)

    def test_swagger_ui_is_public(self):
        response = self.client.get(reverse("swagger-ui"))

        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_redoc_is_public(self):
        response = self.client.get(reverse("redoc"))

        self.assertEqual(response.status_code, status.HTTP_200_OK)
