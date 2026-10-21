#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  Chapitre  : 28 — Sécurité des API (OWASP API Top 10)
#  Exercice  : 1 (Débutant) — Tester l'exposition de données d'une API
#  Version   : kali-rolling 2026.2 (curl, jq), vuln-api (Flask, VULN_MODE)
#  Exécution : bash scripts/08-web-cloud-devsecops/28-kali_api_surexposition.sh
#              (depuis lab/ ; nécessite `make up-pentest`)
#  Statut    : VALIDÉ (2026-08-12)
#
#  Adaptation Docker : le manuel utilise `api.lab` ; le lab utilise
#  le nom de conteneur `vuln-api:5000`. La correction (sérialisation
#  sur liste blanche) est pilotée par VULN_MODE=fixed.
# ─────────────────────────────────────────────────────────────
set -euo pipefail
cd "$(dirname "$0")/../.."   # → lab/

echo "== Ch28 Ex1 — Surexposition de données (API3) =="
fail=0

wait_healthy() {
  local svc=$1
  for i in $(seq 1 30); do
    [ "$(docker inspect --format '{{.State.Health.Status}}' "seclab-$svc" 2>/dev/null)" = "healthy" ] && return 0
    sleep 1
  done
  return 1
}

# 1. Mode vulnérable : champs internes exposés
docker compose up -d vuln-api >/dev/null
wait_healthy vuln-api
out=$(docker compose exec -T kali bash -c '
set -e
echo "--- endpoint de liste ---"
curl -s "http://vuln-api:5000/v1/items?limit=5" | python3 -c "import json,sys; d=json.load(sys.stdin); print(\"champs:\", sorted(d[\"data\"][0].keys()))"
echo "--- endpoint de détail ---"
curl -s "http://vuln-api:5000/v1/items/1" | python3 -c "import json,sys; d=json.load(sys.stdin); print(\"champs:\", sorted(d.keys()))"
')
echo "$out"
echo "$out" | grep -q "password_hash" && echo "✓ password_hash exposé (mode vulnérable)" || { echo "✗ password_hash absent"; fail=1; }
echo "$out" | grep -q "internal_note" && echo "✓ internal_note exposé (mode vulnérable)" || { echo "✗ internal_note absent"; fail=1; }

# 2. Mode corrigé : sérialisation sur liste blanche
VULN_MODE=fixed docker compose up -d vuln-api >/dev/null
wait_healthy vuln-api
out2=$(docker compose exec -T kali bash -c '
set -e
curl -s "http://vuln-api:5000/v1/items/1" | python3 -c "import json,sys; d=json.load(sys.stdin); print(\"champs:\", sorted(d.keys()))"
')
echo "$out2"
echo "$out2" | grep -q "password_hash" && { echo "✗ password_hash encore exposé en mode corrigé"; fail=1; } || echo "✓ password_hash retiré (mode corrigé)"
echo "$out2" | grep -q "internal_note" && { echo "✗ internal_note encore exposé en mode corrigé"; fail=1; } || echo "✓ internal_note retiré (mode corrigé)"

# 3. Retour au mode vulnérable (défaut)
docker compose up -d vuln-api >/dev/null
wait_healthy vuln-api

echo
if [ "$fail" -eq 0 ]; then
  echo "✅ Ch28 Ex1 : VALIDÉ"
else
  echo "❌ Ch28 Ex1 : ÉCHEC"
  exit 1
fi
