import time

from core.metrics import (
    HTTP_REQUESTS,
    HTTP_REQUEST_DURATION,
)


class PrometheusMiddleware:
    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        start = time.time()

        response = self.get_response(request)

        HTTP_REQUESTS.labels(
            method=request.method,
            endpoint=request.path,
            status=response.status_code,
        ).inc()

        HTTP_REQUEST_DURATION.labels(
            method=request.method,
            endpoint=request.path,
        ).observe(time.time() - start)

        return response