#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  Chapitre  : 27 — Sécurité des applications web
#  Exercice  : 1 (Débutant) — Analyser les en-têtes d'une application de test
#  Version   : nginx 1.27-alpine (edge), web-lab (nginx, SECURITY_HEADERS)
#  Exécution : bash scripts/08-web-cloud-devsecops/27-host_en_tetes_web.sh
#              (depuis lab/ ; nécessite `make up`)
#  Statut    : VALIDÉ (2026-08-12)
#
#  Adaptation Docker : le manuel utilise une IP VirtualBox ; le lab
#  passe par le service edge (127.0.0.1:18084 → web-lab). La bascule
#  « configuration à ajouter » est pilotée par SECURITY_HEADERS=on.
# ─────────────────────────────────────────────────────────────
set -euo pipefail
cd "$(dirname "$0")/../.."   # → lab/

echo "== Ch27 Ex1 — En-têtes de sécurité (web-lab) =="
fail=0

wait_healthy() {
  local svc=$1
  for i in $(seq 1 30); do
    [ "$(docker inspect --format '{{.State.Health.Status}}' "seclab-$svc" 2>/dev/null)" = "healthy" ] && return 0
    sleep 1
  done
  return 1
}

# 1. Mode OFF (défaut) : en-têtes de sécurité absents
docker compose up -d web-lab >/dev/null
wait_healthy web-lab
off=$(curl -sI http://127.0.0.1:18084/)
echo "--- en-têtes (mode off) ---"
echo "$off" | grep -iE "strict-transport|content-security|x-content-type" || echo "(aucun en-tête de sécurité)"

# 2. Mode ON : en-têtes présents (HSTS, CSP, nosniff)
SECURITY_HEADERS=on docker compose up -d web-lab >/dev/null
wait_healthy web-lab
on=$(curl -sI http://127.0.0.1:18084/)
echo "--- en-têtes (mode on) ---"
echo "$on" | grep -iE "strict-transport|content-security|x-content-type"

# 3. Vérifications
echo
echo "--- Vérifications ---"
if echo "$off" | grep -qiE "strict-transport|content-security|x-content-type"; then
  echo "✗ en-têtes présents en mode off (attendu : absents)"; fail=1
else
  echo "✓ mode off : aucun en-tête de sécurité (écart documenté)"
fi
echo "$on" | grep -qi "strict-transport-security" && echo "✓ HSTS présent (mode on)" || { echo "✗ HSTS absent"; fail=1; }
echo "$on" | grep -qi "content-security-policy" && echo "✓ CSP présent (mode on)" || { echo "✗ CSP absent"; fail=1; }
echo "$on" | grep -qi "x-content-type-options: nosniff" && echo "✓ nosniff présent (mode on)" || { echo "✗ nosniff absent"; fail=1; }

# 4. Retour au mode OFF (défaut)
docker compose up -d web-lab >/dev/null
wait_healthy web-lab

echo
if [ "$fail" -eq 0 ]; then
  echo "✅ Ch27 Ex1 : VALIDÉ"
else
  echo "❌ Ch27 Ex1 : ÉCHEC"
  exit 1
fi
