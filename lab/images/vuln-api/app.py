#!/usr/bin/env python3
# ─────────────────────────────────────────────────────────────
#  VULN-API — API vulnérable du laboratoire (Ch27-28)
#
#  Endpoints :
#    Ch27 : POST /api/login, GET /api/items/{id}
#    Ch28 : GET /v1/items?limit=N, GET /v1/items/{id},
#           POST /v1/auth, GET /v1/customers/{id},
#           GET /v1/users/me, POST /v1/login
#
#  Bascule VULN_MODE (vulnerable | fixed) :
#    - vulnerable : BOLA/IDOR sans contrôle de propriétaire,
#                   champs sur-exposés (password_hash, internal_note),
#                   erreurs verbeuses (API7), pas de rate-limit.
#    - fixed      : contrôle de propriétaire (403), sérialisation
#                   en liste blanche, erreurs génériques, rate-limit.
#
#  Comptes : A / passA123, B / passB456  (fictifs, labo uniquement)
# ─────────────────────────────────────────────────────────────
import os
import json
import time
import base64
import hashlib
import hmac
import threading

from flask import Flask, request, jsonify

app = Flask(__name__)

VULN_MODE = os.environ.get("VULN_MODE", "vulnerable")
RATE_LIMIT = int(os.environ.get("RATE_LIMIT", "20"))

# Clé de signature JWT — fictive, labo uniquement
SECRET = "seclab-jwt-secret-fictif"

# ── Comptes A et B (fictifs) ──────────────────────────────────
USERS = {
    "A": {"password": "passA123", "role": "user"},
    "B": {"password": "passB456", "role": "user"},
}

# ── Objets par propriétaire (Ch27 : /api/items) ──────────────
ITEMS = {
    1: {"id": 1, "name": "Laptop", "description": "Portable de test",
        "owner": "A", "password_hash": "$2y$10$abc123hashA",
        "internal_note": "à migrer", "created_at": "2026-01-01"},
    2: {"id": 2, "name": "Serveur", "description": "Serveur de test",
        "owner": "A", "password_hash": "$2y$10$def456hashA",
        "internal_note": "obsolète", "created_at": "2026-01-02"},
    3: {"id": 3, "name": "Routeur", "description": "Routeur de test",
        "owner": "B", "password_hash": "$2y$10$ghi789hashB",
        "internal_note": "fragile", "created_at": "2026-01-03"},
}

# ── Clients par propriétaire (Ch28 : /v1/customers) ───────────
CUSTOMERS = {
    1: {"id": 1, "name": "Client A", "owner": "A", "email": "a@lab.local"},
    2: {"id": 2, "name": "Client B", "owner": "B", "email": "b@lab.local"},
}

# Champs autorisés en mode "fixed" (liste blanche, API3)
SAFE_FIELDS = ("id", "name", "description", "created_at")


# ── JWT minimal (stdlib, pour l'exercice de décodage Ch28) ───
def _b64url(data: bytes) -> str:
    return base64.urlsafe_b64encode(data).rstrip(b"=").decode()


def make_token(user: str) -> str:
    header = {"alg": "HS256", "typ": "JWT"}
    payload = {"sub": user, "iat": int(time.time()), "exp": int(time.time()) + 3600}
    h = _b64url(json.dumps(header).encode())
    p = _b64url(json.dumps(payload).encode())
    sig = _b64url(hmac.new(SECRET.encode(), f"{h}.{p}".encode(), hashlib.sha256).digest())
    return f"{h}.{p}.{sig}"


def decode_token(token: str):
    try:
        h, p, s = token.split(".")
        expected = _b64url(hmac.new(SECRET.encode(), f"{h}.{p}".encode(), hashlib.sha256).digest())
        if not hmac.compare_digest(s, expected):
            return None
        payload = json.loads(base64.urlsafe_b64decode(p + "=" * (-len(p) % 4)))
        return payload.get("sub")
    except Exception:
        return None


def current_user():
    auth = request.headers.get("Authorization", "")
    if auth.startswith("Bearer "):
        return decode_token(auth[7:])
    return None


def json_body():
    """Parse le corps JSON quel que soit le Content-Type.

    Les commandes du manuel utilisent `curl -d '{"user":"A",...}'` sans
    header `Content-Type: application/json` (curl envoie alors
    application/x-www-form-urlencoded). Pour que ces commandes fonctionnent
    telles quelles, l'API accepte le JSON même sans le bon content-type.
    NB : en réel, une API stricte renverrait 415/400 — toujours préciser
    le header Content-Type (bonne pratique, cf. VALIDATION.md).
    """
    data = request.get_json(silent=True)
    if data is not None:
        return data
    raw = request.get_data(as_text=True)
    try:
        return json.loads(raw) if raw else {}
    except Exception:
        return {}


# ── Rate-limit simple (fenêtre glissante de 60 s) ─────────────
_hits = {}
_lock = threading.Lock()


def rate_limited():
    ip = request.remote_addr
    now = time.time()
    with _lock:
        window = [t for t in _hits.get(ip, []) if now - t < 60]
        if len(window) >= RATE_LIMIT:
            return True
        window.append(now)
        _hits[ip] = window
    return False


# ═════════════════════════════════════════════════════════════
#  CH27 — Sécurité des applications web
# ═════════════════════════════════════════════════════════════

@app.route("/api/login", methods=["POST"])
def api_login():
    data = json_body()
    user, pwd = data.get("user"), data.get("pass")
    if user in USERS and USERS[user]["password"] == pwd:
        return jsonify({"token": make_token(user)})
    return jsonify({"error": "identifiants invalides"}), 401


@app.route("/api/items/<int:item_id>", methods=["GET"])
def api_item(item_id):
    user = current_user()
    if not user:
        return jsonify({"error": "authentification requise"}), 401
    item = ITEMS.get(item_id)
    if not item:
        return jsonify({"error": "introuvable"}), 404
    if VULN_MODE == "vulnerable":
        # BOLA / IDOR : aucun contrôle de propriétaire
        return jsonify(item)
    if item["owner"] != user:
        return jsonify({"error": "accès refusé"}), 403
    return jsonify(item)


# ═════════════════════════════════════════════════════════════
#  CH28 — Sécurité des API (OWASP API Top 10)
# ═════════════════════════════════════════════════════════════

@app.route("/v1/auth", methods=["POST"])
def v1_auth():
    data = json_body()
    user, pwd = data.get("user"), data.get("password")
    if user in USERS and USERS[user]["password"] == pwd:
        return jsonify({"access_token": make_token(user), "token_type": "Bearer"})
    return jsonify({"error": "identifiants invalides"}), 401


@app.route("/v1/items", methods=["GET"])
def v1_items():
    if rate_limited():
        return jsonify({"error": "trop de requêtes"}), 429
    limit = request.args.get("limit", default=10, type=int)
    items = list(ITEMS.values())[:limit]
    if VULN_MODE == "vulnerable":
        # API3 : sur-exposition de données
        return jsonify({"data": items})
    safe = [{k: v for k, v in it.items() if k in SAFE_FIELDS} for it in items]
    return jsonify({"data": safe})


@app.route("/v1/items/<int:item_id>", methods=["GET"])
def v1_item(item_id):
    item = ITEMS.get(item_id)
    if not item:
        return jsonify({"error": "introuvable"}), 404
    if VULN_MODE == "vulnerable":
        return jsonify(item)
    return jsonify({k: v for k, v in item.items() if k in SAFE_FIELDS})


@app.route("/v1/customers/<int:customer_id>", methods=["GET"])
def v1_customer(customer_id):
    user = current_user()
    if not user:
        return jsonify({"error": "authentification requise"}), 401
    cust = CUSTOMERS.get(customer_id)
    if not cust:
        return jsonify({"error": "introuvable"}), 404
    if VULN_MODE == "vulnerable":
        # API1 : BOLA — accès aux objets d'un autre utilisateur
        return jsonify(cust)
    if cust["owner"] != user:
        return jsonify({"error": "accès refusé"}), 403
    return jsonify(cust)


@app.route("/v1/users/me", methods=["GET"])
def v1_me():
    user = current_user()
    if not user:
        return jsonify({"error": "authentification requise"}), 401
    return jsonify({"user": user, "role": USERS[user]["role"]})


@app.route("/v1/login", methods=["POST"])
def v1_login():
    data = json_body()
    user, pwd = data.get("user"), data.get("password")
    if user in USERS and USERS[user]["password"] == pwd:
        return jsonify({"message": "connexion réussie"})
    if VULN_MODE == "vulnerable":
        # API7 : erreur verbeuse (trace) — fuite d'information
        return jsonify({
            "error": f"Traceback (most recent call last): KeyError('{user}') — "
                     f"utilisateur inconnu ou mot de passe invalide"
        }), 401
    return jsonify({"error": "identifiants invalides"}), 401


@app.route("/health")
def health():
    return jsonify({"status": "ok", "mode": VULN_MODE})


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
