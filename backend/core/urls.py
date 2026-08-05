from django.urls import path
from . import views

urlpatterns = [
    path('video', views.video),
    path('shop', views.shop),
    path('payments', views.payments),
]