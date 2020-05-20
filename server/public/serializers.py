from rest_framework import serializers


class ProfilePictureSerializer(serializers.Serializer):
    file = serializers.ImageField(required=True)
