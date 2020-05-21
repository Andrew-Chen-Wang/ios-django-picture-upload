from pathlib import Path

from django.core.files.uploadedfile import SimpleUploadedFile
from django.test import override_settings
from rest_framework.test import APIRequestFactory, APITestCase

from public import views

# TODO You need to add a picture yourself
class PictureTestCase(APITestCase):
    @override_settings(IN_TEST=True)
    def test_upload_picture(self):
        view = views.ServerUploadPicView.as_view()
        arf = APIRequestFactory()
        with (Path().cwd().parent / "server/public/hi.jpg").open("rb") as fp:
            file = SimpleUploadedFile("hi.jpg", fp.read(), content_type="image/jpg")
            request = arf.post(
                "/api/v1/profile/picture/",
                data={"file": file},
                format="multipart"
            )
            request.META["HTTP_CONTENT_DISPOSITION"] = "attachment; filename=hi.jpg"
            response = view(request)
        assert response.status_code == 201, f"Response {response.data}"
