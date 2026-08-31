import time

from django.http import JsonResponse, HttpResponse
from prometheus_client import generate_latest, CONTENT_TYPE_LATEST

from core.metrics import (
    VIDEO_REQUESTS,
    SHOP_REQUESTS,
    PAYMENT_REQUESTS,
)

def video(request):
    VIDEO_REQUESTS.inc()
    response = JsonResponse({
        "module": "Video",
        "status": "Streaming active",
        "items": [
            "movie1",
            "movie2",
            "movie3"
        ]
    })


def shop(request):
    SHOP_REQUESTS.inc()

    return JsonResponse({
        "module": "Shop",
        "status": "Open",
        "items": [
            "hat",
            "shirt",
            "shoes"
        ]
    })


def payments(request):
    PAYMENT_REQUESTS.inc()

    return JsonResponse({
        "module": "Payments",
        "status": "Gateway ready",
        "balance": 150.00
    })


def health(request):
    return JsonResponse({
        "status": "ok"
    })


def metrics(request):
    return HttpResponse(
        generate_latest(),
        content_type=CONTENT_TYPE_LATEST
    )
