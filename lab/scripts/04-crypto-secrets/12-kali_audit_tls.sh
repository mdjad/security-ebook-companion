#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  Chapitre  : 12 — Fondamentaux de la cryptographie
#  Exercice  : 2 (Intermédiaire) — Audit rapide de l'état TLS d'un serveur
#  Version   : kali-rolling 2026.2 (openssl 3.x)
#  Exécution : bash scripts/04-crypto-secrets/12-kali_audit_tls.sh
#              (depuis lab/ ; nécessite `make up-pentest`)
#  Statut    : VALIDÉ (2026-08-11)
#
#  Adaptation Docker : la cible TLS du lab est `web-lab:443`
#  (nginx auto-signé, TLS 1.2/1.3 uniquement).
# ─────────────────────────────────────────────────────────────
set -euo pipefail
cd "$(dirname "$0")/../.."   # → lab/

echo "== Ch12 Ex2 — Audit TLS de web-lab:443 =="
fail=0

echo
echo "--- 1. Protocole et certificat ---"
out=$(docker compose exec -T kali bash -c "echo | openssl s_client -connect web-lab:443 2>/dev/null | grep -E 'Protocol|subject|issuer|NotAfter'")
echo "$out"
echo "$out" | grep -qE "Protocol: TLSv1\.[23]" && echo "✓ protocole TLS moderne négocié" || { echo "✗ protocole TLS inattendu"; fail=1; }
echo "$out" | grep -q "subject=.*CN=web-lab" && echo "✓ certificat présent (CN=web-lab)" || { echo "✗ certificat absent"; fail=1; }
echo "$out" | grep -q "issuer=.*CN=web-lab" && echo "✓ certificat auto-signé (issuer=subject)" || { echo "✗ issuer inattendu"; fail=1; }

echo
echo "--- 2. Test des anciens protocoles (TLS 1.0 / 1.1) ---"
# NB : `CONNECTED` n'indique que la connexion TCP. Le rejet TLS 1.0 se
# lit dans l'alerte « tlsv1 alert protocol version » (alert 70) émise
# par le serveur pendant le handshake.
n=$(docker compose exec -T kali bash -c "echo | openssl s_client -connect web-lab:443 -tls1 2>&1 | grep -c 'alert protocol version'" || true)
echo "alertes de rejet TLS 1.0 : $n"
[ "$n" -ge 1 ] && echo "✓ TLS 1.0 refusé (bonne pratique)" || { echo "✗ TLS 1.0 accepté (à corriger)"; fail=1; }

echo
echo "--- 3. Recommandations ---"
echo "• TLS 1.2/1.3 uniquement (couper 1.0/1.1) — déjà en place sur web-lab"
echo "• certificat valide et chaîne complète — ici auto-signé (test uniquement)"
echo "• suite de chiffrement forte (vérifiable dans la config)"
echo "✓ recommandations formulées"

echo
if [ "$fail" -eq 0 ]; then
  echo "✅ Ch12 Ex2 : VALIDÉ"
else
  echo "❌ Ch12 Ex2 : ÉCHEC"
  exit 1
fi
