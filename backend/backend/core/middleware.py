import time

from .metrics import (
    HTTP_REQUESTS,
    HTTP_REQUEST_DURATION,
)


class PrometheusMiddleware:
    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        start = time.time()

        response = self.get_response(request)

        duration = time.time() - start

        endpoint = request.path
        status = str(response.status_code)

        HTTP_REQUESTS.labels(
            method=request.method,
            endpoint=endpoint,
            status=status,
        ).inc()

        HTTP_REQUEST_DURATION.labels(
            method=request.method,
            endpoint=endpoint,
        ).observe(duration)

        return response