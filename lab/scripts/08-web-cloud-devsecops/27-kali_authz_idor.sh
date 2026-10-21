#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  Chapitre  : 27 — Sécurité des applications web
#  Exercice  : 2 (Intermédiaire) — Tester AuthZ dans le cadre autorisé
#  Version   : kali-rolling 2026.2 (curl, jq), vuln-api (Flask, VULN_MODE)
#  Exécution : bash scripts/08-web-cloud-devsecops/27-kali_authz_idor.sh
#              (depuis lab/ ; nécessite `make up-pentest`)
#  Statut    : VALIDÉ (2026-08-12)
#
#  Adaptation Docker : le manuel utilise `app.lab` ; le lab utilise
#  le nom de conteneur `vuln-api:5000`. La correction côté serveur
#  est pilotée par VULN_MODE=fixed (vérification d'appartenance).
# ─────────────────────────────────────────────────────────────
set -euo pipefail
cd "$(dirname "$0")/../.."   # → lab/

echo "== Ch27 Ex2 — IDOR / contrôle d'accès (vuln-api) =="
fail=0

wait_healthy() {
  local svc=$1
  for i in $(seq 1 30); do
    [ "$(docker inspect --format '{{.State.Health.Status}}' "seclab-$svc" 2>/dev/null)" = "healthy" ] && return 0
    sleep 1
  done
  return 1
}

# 1. Mode vulnérable : A accède à l'objet de B (id 3)
docker compose up -d vuln-api >/dev/null
wait_healthy vuln-api
out=$(docker compose exec -T kali bash -c '
set -e
TOKEN=$(curl -s -X POST http://vuln-api:5000/api/login -H "Content-Type: application/json" -d "{\"user\":\"A\",\"pass\":\"passA123\"}" | python3 -c "import json,sys; print(json.load(sys.stdin).get(\"token\",\"\"))")
echo "--- objet de B (id 3) avec le jeton de A ---"
curl -s -o /dev/null -w "HTTP %{http_code}\n" -H "Authorization: Bearer $TOKEN" http://vuln-api:5000/api/items/3
curl -s -H "Authorization: Bearer $TOKEN" http://vuln-api:5000/api/items/3 | python3 -c "import json,sys; d=json.load(sys.stdin); print(\"owner:\", d.get(\"owner\"), \"| id:\", d.get(\"id\"))"
')
echo "$out"
echo "$out" | grep -q "HTTP 200" && echo "✓ mode vulnérable : accès à l'objet de B (200)" || { echo "✗ accès refusé en mode vulnérable"; fail=1; }
echo "$out" | grep -q "owner: B" && echo "✓ données de B exposées (IDOR confirmé)" || { echo "✗ données de B non exposées"; fail=1; }

# 2. Mode corrigé : vérification d'appartenance côté serveur → 403
VULN_MODE=fixed docker compose up -d vuln-api >/dev/null
wait_healthy vuln-api
out2=$(docker compose exec -T kali bash -c '
set -e
TOKEN=$(curl -s -X POST http://vuln-api:5000/api/login -H "Content-Type: application/json" -d "{\"user\":\"A\",\"pass\":\"passA123\"}" | python3 -c "import json,sys; print(json.load(sys.stdin).get(\"token\",\"\"))")
curl -s -o /dev/null -w "HTTP %{http_code}\n" -H "Authorization: Bearer $TOKEN" http://vuln-api:5000/api/items/3
')
echo "$out2"
echo "$out2" | grep -q "HTTP 403" && echo "✓ mode corrigé : accès refusé (403)" || { echo "✗ accès non refusé en mode corrigé"; fail=1; }

# 3. Retour au mode vulnérable (défaut)
docker compose up -d vuln-api >/dev/null
wait_healthy vuln-api

echo
if [ "$fail" -eq 0 ]; then
  echo "✅ Ch27 Ex2 : VALIDÉ"
else
  echo "❌ Ch27 Ex2 : ÉCHEC"
  exit 1
fi
