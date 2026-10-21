#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  Chapitre  : 07 — Réseaux et protocoles
#  Exercice  : 2 (Intermédiaire) — Diagnostiquer une panne service par couche
#  Version   : kali-rolling 2026.2 (dig 9.20, ss, tcpdump, curl)
#  Exécution : bash scripts/02-socle-technique/07-kali_diagnostic_couches.sh
#              (depuis lab/ ; nécessite `make up-pentest`)
#  Statut    : VALIDÉ (2026-08-11)
#
#  Adaptation Docker : le « site interne » du manuel (intranet.local)
#  devient la cible du lab `vuln-host` (résolue par le DNS Docker).
#  La méthode par couches est identique.
# ─────────────────────────────────────────────────────────────
set -euo pipefail
cd "$(dirname "$0")/../.."   # → lab/

echo "== Ch07 Ex2 — Diagnostic par couches (cible : vuln-host) =="
fail=0

echo
echo "--- 1. Résolution DNS fonctionne-t-elle ? ---"
out=$(docker compose exec -T kali bash -c "dig +short vuln-host")
echo "vuln-host -> ${out:-<vide>}"
[ -n "$out" ] && echo "✓ DNS OK (résolution par nom de conteneur)" || { echo "✗ DNS en échec"; fail=1; }

echo
echo "--- 2. Le service écoute-t-il localement ? ---"
out=$(docker compose exec -T vuln-host bash -c "ss -tulpn | grep ':80 '")
echo "$out"
echo "$out" | grep -q ":80 " && echo "✓ service HTTP en écoute sur la cible" || { echo "✗ port 80 non écouté"; fail=1; }

echo
echo "--- 3. Le trafic arrive-t-il ? (tcpdump port 80) ---"
# NB : kali est sur DEUX réseaux (seclab + seclab-internal) ; le
# trafic vers vuln-host passe par eth1 → capture sur `any`.
out=$(docker compose exec -T kali bash -c '
  timeout 15 tcpdump -i any -nn port 80 -c 3 2>/dev/null &
  TPID=$!
  sleep 2
  curl -s http://vuln-host/ -o /dev/null
  wait $TPID || true
')
echo "$out" | head -6
echo "$out" | grep -qE "\.80:.*Flags \[S\]" && echo "✓ trafic HTTP reçu" || { echo "✗ aucun trafic sur le port 80"; fail=1; }

echo
echo "--- 4. Test applicatif direct ---"
out=$(docker compose exec -T kali bash -c "curl -s -o /dev/null -w '%{http_code}' http://vuln-host/")
echo "HTTP $out"
[ "$out" = "200" ] && echo "✓ application répond (HTTP 200)" || { echo "✗ réponse inattendue"; fail=1; }

echo
if [ "$fail" -eq 0 ]; then
  echo "✅ Ch07 Ex2 : VALIDÉ"
else
  echo "❌ Ch07 Ex2 : ÉCHEC"
  exit 1
fi
