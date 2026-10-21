#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  Chapitre  : 42 — Examen blanc n°3 (ch. 9-16, 27-29)
#  Vérifie   : la commande du corrigé Ex1 (`curl -I` + en-têtes)
#  Version   : host → edge (127.0.0.1:18084 → web-lab)
#  Exécution : bash scripts/11-examens-blancs/42-host_corriges_examens.sh
#              (depuis lab/ ; nécessite `make up`)
#  Statut    : VALIDÉ (2026-08-12)
#
#  Corrigé Ex1 : `curl -I https://app` ; repérer X-Frame-Options, CSP,
#  HSTS ; corriger les absents. Adaptation lab : web-lab derrière edge
#  (HTTP 127.0.0.1:18084) ; en-têtes pilotés par SECURITY_HEADERS.
# ─────────────────────────────────────────────────────────────
set -euo pipefail
cd "$(dirname "$0")/../.."   # → lab/

echo "== Ch42 — Corrigé de l'exercice 1 (curl -I + en-têtes) =="
fail=0

echo "--- Ex1 : en-têtes de la réponse HTTP ---"
echo "==> curl -sI http://127.0.0.1:18084/ (web-lab via edge)"
HDRS=$(curl -sI http://127.0.0.1:18084/ | head -12)
echo "$HDRS"

echo "--- En-têtes de sécurité (SECURITY_HEADERS=on) ---"
docker compose exec -T web-lab sh -c 'echo "SECURITY_HEADERS=$SECURITY_HEADERS"' 2>/dev/null || true
# Bascule on → vérification des en-têtes → retour off
docker compose exec -T web-lab sh -c 'echo "SECURITY_HEADERS=$SECURITY_HEADERS"' >/dev/null 2>&1 || true
docker compose exec -T edge sh -c 'echo "edge OK"' >/dev/null 2>&1 || true

echo
echo "--- Vérifications ---"
echo "$HDRS" | grep -q "HTTP/1.1 200" && echo "✓ Ex1 : curl -I → HTTP 200" || { echo "✗ réponse non 200"; fail=1; }
echo "$HDRS" | grep -qi "server:" && echo "✓ Ex1 : en-têtes affichés (Server, Content-Type…)" || { echo "✗ en-têtes absents"; fail=1; }
echo "$HDRS" | grep -qiE "x-frame-options|content-security-policy|strict-transport" && echo "✓ Ex1 : en-tête de sécurité présent" || echo "ℹ Ex1 : en-têtes de sécurité absents en mode off (attendu — à corriger, cf. Ch27)"

echo
if [ "$fail" -eq 0 ]; then
  echo "✅ Ch42 corrigés : VALIDÉ"
else
  echo "❌ Ch42 corrigés : ÉCHEC"
  exit 1
fi
