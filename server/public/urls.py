from django.urls import include, path
from rest_framework import routers
from rest_framework_simplejwt.views import (TokenObtainPairView,
                                            TokenRefreshView)

from . import views


router = routers.DefaultRouter()
router.register("ping", views.PingViewSet, basename="ping")
router.register("presigned", views.PreSignedPostViewSet, basename="presigned")

urlpatterns = [
    path("api/token/access/", TokenRefreshView.as_view(), name="token_get_access"),
    path("api/token/both/", TokenObtainPairView.as_view(), name="token_obtain_pair"),
    path("api/", include(router.urls)),
    path("profile/", views.ServerUploadPicView.as_view()),
]

"""
- For the first view, you send the refresh token to get a new access token.
- For the second view, you send the client credentials (username and password)
  to get BOTH a new access and refresh token.
"""
