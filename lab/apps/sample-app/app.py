#!/usr/bin/env python3
# ─────────────────────────────────────────────────────────────
#  SAMPLE-APP — application de test du laboratoire (Ch29-30)
#  Serveur HTTP minimal sur le port 8000, exécuté en non-root.
# ─────────────────────────────────────────────────────────────
from http.server import HTTPServer, BaseHTTPRequestHandler


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header("Content-Type", "text/plain; charset=utf-8")
        self.end_headers()
        self.wfile.write(b"sample-app: application de test du laboratoire\n")

    def log_message(self, fmt, *args):
        pass  # silencieux


if __name__ == "__main__":
    HTTPServer(("0.0.0.0", 8000), Handler).serve_forever()
