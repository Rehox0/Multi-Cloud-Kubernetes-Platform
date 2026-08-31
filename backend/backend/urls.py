from django.contrib import admin
from django.urls import path

from . import views


urlpatterns = [
    path("admin/", admin.site.urls),

    path("api/video", views.video),
    path("api/shop", views.shop),
    path("api/payments", views.payments),

    path("api/health", views.health),
    path("api/ready", views.health),

    path("metrics", views.metrics),
]