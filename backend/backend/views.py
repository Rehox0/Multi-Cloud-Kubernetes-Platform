import time

from django.http import JsonResponse, HttpResponse
from prometheus_client import generate_latest, CONTENT_TYPE_LATEST

from core.metrics import (
    VIDEO_REQUESTS,
    SHOP_REQUESTS,
    PAYMENT_REQUESTS,
    UDP_PACKETS_RECEIVED,
    UDP_BYTES_RECEIVED,
)

def video(request):
    start = time.time()
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
    return response


def shop(request):
    start = time.time()
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

    return response


def payments(request):
    start = time.time()
    PAYMENT_REQUESTS.inc()

    return JsonResponse({
        "module": "Payments",
        "status": "Gateway ready",
        "balance": 150.00
    })

    return response


def health(request):
    return JsonResponse({
        "status": "ok"
    })


def metrics(request):
    return HttpResponse(
        generate_latest(),
        content_type=CONTENT_TYPE_LATEST
    )
