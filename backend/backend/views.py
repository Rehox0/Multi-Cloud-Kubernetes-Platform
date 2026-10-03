import time
import json
import os

from django.http import JsonResponse, HttpResponse
from prometheus_client import generate_latest, CONTENT_TYPE_LATEST
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_http_methods

from backend.core.models import Event
from backend.core.metrics import (
    VIDEO_REQUESTS,
    SHOP_REQUESTS,
    PAYMENT_REQUESTS,
    UDP_PACKETS_RECEIVED,
    UDP_BYTES_RECEIVED,
)

def video(request):
    start = time.time()
    VIDEO_REQUESTS.inc()
    return JsonResponse({
        "module": "Video",
        "status": "Streaming active",
        "items": [
            "movie1",
            "movie2",
            "movie3"
        ]
    })


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


def payments(request):
    start = time.time()
    PAYMENT_REQUESTS.inc()

    return JsonResponse({
        "module": "Payments",
        "status": "Gateway ready",
        "balance": 150.00
    })


def health(request):
    return JsonResponse({
        "status": "ok",
        "cloud": os.getenv("CLOUD_PROVIDER", "unknown"),
        "region": os.getenv("CLOUD_REGION", "unknown"),
        "platform": os.getenv("BACKEND_PLATFORM", "unknown"),
    })


def metrics(request):
    return HttpResponse(
        generate_latest(),
        content_type=CONTENT_TYPE_LATEST
    )

@csrf_exempt
@require_http_methods(["GET", "POST"])
def events(request):
    if request.method == "GET":
        events = Event.objects.order_by("-created_at")

        return JsonResponse([
            {
                "id": event.id,
                "event_type": event.event_type,
                "value": event.value,
                "created_at": event.created_at.isoformat(),
            }
            for event in events
        ], safe=False)

    if request.method == "POST":
        return create_event(request)

    return JsonResponse({"error": "Method not allowed"}, status=405)

def create_event(request):
    data = json.loads(request.body)

    event = Event.objects.create(
        event_type=data["event_type"],
        value=data["value"],
    )

    return JsonResponse({
        "id": event.id,
        "event_type": event.event_type,
        "value": event.value,
    }, status=201)
    