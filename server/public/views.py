from rest_framework.viewsets import GenericViewSet
from rest_framework.mixins import ListModelMixin
from rest_framework.response import Response
from rest_framework.status import HTTP_200_OK
from rest_framework.permissions import IsAuthenticated


class PingViewSet(GenericViewSet, ListModelMixin):
    permission_classes = [IsAuthenticated]

    def list(self, request, *args, **kwargs):
        return Response(
            data={"id": request.GET.get("id")},
            status=HTTP_200_OK
        )



from rest_framework.parsers import FileUploadParser
from rest_framework.views import APIView
from django.utils.crypto import get_random_string
from rest_framework import status
from django.conf import settings
from django.core.files.uploadedfile import TemporaryUploadedFile

import boto3
from botocore.exceptions import ClientError
import os

from .serializers import ProfilePictureSerializer


class ImageUploadParser(FileUploadParser):
    media_type = 'image/*'


class ServerUploadPicView(APIView):
    parser_classes = (FileUploadParser,)

    def post(self, request):
        serializer = ProfilePictureSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        file_obj: TemporaryUploadedFile = serializer.validated_data["file"]
        new_file_name = get_random_string(12)
        if settings.DEBUG:
            s3_client = boto3.client(
                "s3",
                aws_access_key_id=settings.AWS_ACCESS_KEY_ID,
                aws_secret_access_key=settings.AWS_SECRET_ACCESS_KEY
            )
        else:
            # Your EC2 machine should not have .env files
            # And it should just be configured with your IAM credentials.
            s3_client = boto3.client("s3")

        # Begin upload
        try:
            _AWS_EXPIRY = 60 * 60 * 24 * 7
            s3_client.upload_file(
                Bucket=settings.AWS_STORAGE_BUCKET_NAME,
                Filename=file_obj.temporary_file_path(),
                Key=new_file_name + str(os.path.splitext(file_obj.name)[1]),  # The latter is the extension
                ExtraArgs={
                    "ACL": "public-read",
                    "CacheControl": f"max-age={_AWS_EXPIRY}, s-maxage={_AWS_EXPIRY}, must-revalidate"
                }
            )

        except ClientError as e:
            import logging
            logging.error(e)
            return Response(status=status.HTTP_500_INTERNAL_SERVER_ERROR)
        print(new_file_name + str(os.path.splitext(file_obj.name)[1]))
        # We don't need to send back the link since the device should just update by itself.
        return Response(status=status.HTTP_201_CREATED)

