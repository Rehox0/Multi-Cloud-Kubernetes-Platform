from prometheus_client import Counter, Gauge, Histogram

HTTP_REQUESTS = Counter(
    "app_http_requests_total",
    "Total number of HTTP requests",
    ["method", "endpoint", "status"],
)

HTTP_REQUEST_DURATION = Histogram(
    "app_http_request_duration_seconds",
    "HTTP request duration",
    ["method", "endpoint"],
)

UDP_PACKETS_RECEIVED = Counter(
    "app_udp_packets_received_total",
    "Total number of UDP packets received",
)

UDP_BYTES_RECEIVED = Counter(
    "app_udp_bytes_received_total",
    "Total number of UDP bytes received",
)

UDP_LISTENER_ACTIVE = Gauge(
    "app_udp_listener_active",
    "Whether UDP listener is active",
)