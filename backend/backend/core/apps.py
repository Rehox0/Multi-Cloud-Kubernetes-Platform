import os
import socket
import threading
from django.apps import AppConfig

from .metrics import (
    UDP_PACKETS_RECEIVED,
    UDP_BYTES_RECEIVED,
    UDP_LISTENER_ACTIVE,
)


class CoreConfig(AppConfig):
    default_auto_field = "django.db.models.BigAutoField"
    name = "core"

    def ready(self):
        print("\n\n>>> APPS.PY READY() READY! <<<\n\n", flush=True)
        if os.environ.get("RUN_MAIN") == "true" or not os.environ.get(
            "DJANGO_AUTORELOAD"
        ):
            threading.Thread(target=self._start_udp_listener, daemon=True).start()

    def _start_udp_listener(self):
        try:
            sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
            sock.bind(("0.0.0.0", 9999))
            print(
                "\n[UDP] === Server ready on port 9999 ===",
                flush=True,
            )

            while True:
                data, addr = sock.recvfrom(1024)
                UDP_PACKETS_RECEIVED.inc()
                UDP_BYTES_RECEIVED.inc(len(data))

                print(
                    f"[UDP] Received: '{data.decode().strip()}' from {addr}",
                    flush=True,
                )
        except Exception as e:
            print(f"[UDP Error] Error occurred: {e}", flush=True)