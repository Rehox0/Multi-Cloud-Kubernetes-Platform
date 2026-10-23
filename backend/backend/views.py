import time
import json
import os
import urllib.request
import urllib.error

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

@require_http_methods(["GET"])
def cross_cloud_health(request):
    cloud = os.getenv("CLOUD_PROVIDER", "").strip().lower()

    if cloud == "aws":
        target_url = "http://10.20.4.7/api/health"
        expected_cloud = "azure"
        expected_platform = "AKS"

    elif cloud == "azure":
        target_url = "http://10.0.10.116/api/health"
        expected_cloud = "aws"
        expected_platform = "EKS"

    else:
        return JsonResponse({
            "status": "error",
            "error": f"Unsupported CLOUD_PROVIDER: {cloud or 'not configured'}",
        }, status=500)

    start = time.monotonic()

    try:
        req = urllib.request.Request(
            target_url,
            headers={"Accept": "application/json"},
            method="GET",
        )

        with urllib.request.urlopen(req, timeout=5) as response:
            remote_data = json.loads(response.read().decode("utf-8"))

        latency_ms = round((time.monotonic() - start) * 1000, 2)

        if remote_data.get("status") != "ok":
            raise ValueError("Remote backend health status is not OK")

        actual_cloud = str(remote_data.get("cloud", "")).strip().lower()
        actual_platform = remote_data.get("platform", "")

        if actual_cloud != expected_cloud:
            return JsonResponse({
                "status": "error",
                "error": "Unexpected cloud provider returned by remote backend",
                "expected_cloud": expected_cloud,
                "actual_cloud": remote_data.get("cloud", "unknown"),
            }, status=502)

        return JsonResponse({
            "status": "ok",
            "target_cloud": remote_data.get("cloud", "unknown"),
            "target_platform": actual_platform or expected_platform,
            "region": remote_data.get("region", "unknown"),
            "latency_ms": latency_ms,
        })

    except (
        urllib.error.URLError,
        TimeoutError,
        OSError,
        ValueError,
        json.JSONDecodeError,
    ) as error:
        latency_ms = round((time.monotonic() - start) * 1000, 2)

        return JsonResponse({
            "status": "unavailable",
            "target_cloud": expected_cloud.upper(),
            "target_platform": expected_platform,
            "latency_ms": latency_ms,
            "error": str(error),
        }, status=503)


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
    