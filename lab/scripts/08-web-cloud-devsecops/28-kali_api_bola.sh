#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  Chapitre  : 28 — Sécurité des API (OWASP API Top 10)
#  Exercice  : 2 (Intermédiaire) — Détecter et corriger un BOLA
#  Version   : kali-rolling 2026.2 (curl, jq), vuln-api (Flask, VULN_MODE)
#  Exécution : bash scripts/08-web-cloud-devsecops/28-kali_api_bola.sh
#              (depuis lab/ ; nécessite `make up-pentest`)
#  Statut    : VALIDÉ (2026-08-12)
#
#  Adaptation Docker : le manuel utilise `api.lab` ; le lab utilise
#  le nom de conteneur `vuln-api:5000`. La correction (vérification
#  de propriétaire) est pilotée par VULN_MODE=fixed.
# ─────────────────────────────────────────────────────────────
set -euo pipefail
cd "$(dirname "$0")/../.."   # → lab/

echo "== Ch28 Ex2 — BOLA (API1) =="
fail=0

wait_healthy() {
  local svc=$1
  for i in $(seq 1 30); do
    [ "$(docker inspect --format '{{.State.Health.Status}}' "seclab-$svc" 2>/dev/null)" = "healthy" ] && return 0
    sleep 1
  done
  return 1
}

# 1. Mode vulnérable : A accède au client de B (id 2)
docker compose up -d vuln-api >/dev/null
wait_healthy vuln-api
out=$(docker compose exec -T kali bash -c '
set -e
TOKEN_A=$(curl -s -X POST http://vuln-api:5000/v1/auth -H "Content-Type: application/json" -d "{\"user\":\"A\",\"password\":\"passA123\"}" | python3 -c "import json,sys; print(json.load(sys.stdin).get(\"access_token\",\"\"))")
echo "--- client de B (id 2) avec le jeton de A ---"
curl -s -o /dev/null -w "HTTP %{http_code}\n" -H "Authorization: Bearer $TOKEN_A" http://vuln-api:5000/v1/customers/2
curl -s -H "Authorization: Bearer $TOKEN_A" http://vuln-api:5000/v1/customers/2 | python3 -c "import json,sys; d=json.load(sys.stdin); print(\"owner:\", d.get(\"owner\"), \"| id:\", d.get(\"id\"))"
')
echo "$out"
echo "$out" | grep -q "HTTP 200" && echo "✓ mode vulnérable : accès au client de B (200)" || { echo "✗ accès refusé en mode vulnérable"; fail=1; }
echo "$out" | grep -q "owner: B" && echo "✓ données de B exposées (BOLA confirmé)" || { echo "✗ données de B non exposées"; fail=1; }

# 2. Mode corrigé : vérification de propriétaire → 403
VULN_MODE=fixed docker compose up -d vuln-api >/dev/null
wait_healthy vuln-api
out2=$(docker compose exec -T kali bash -c '
set -e
TOKEN_A=$(curl -s -X POST http://vuln-api:5000/v1/auth -H "Content-Type: application/json" -d "{\"user\":\"A\",\"password\":\"passA123\"}" | python3 -c "import json,sys; print(json.load(sys.stdin).get(\"access_token\",\"\"))")
curl -s -o /dev/null -w "HTTP %{http_code}\n" -H "Authorization: Bearer $TOKEN_A" http://vuln-api:5000/v1/customers/2
')
echo "$out2"
echo "$out2" | grep -q "HTTP 403" && echo "✓ mode corrigé : accès refusé (403)" || { echo "✗ accès non refusé en mode corrigé"; fail=1; }

# 3. Retour au mode vulnérable (défaut)
docker compose up -d vuln-api >/dev/null
wait_healthy vuln-api

echo
if [ "$fail" -eq 0 ]; then
  echo "✅ Ch28 Ex2 : VALIDÉ"
else
  echo "❌ Ch28 Ex2 : ÉCHEC"
  exit 1
fi
