#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  Chapitre  : 06 — Linux et les commandes essentielles de sécurité
#  Exercice  : 2 (Intermédiaire) — Auditer les droits sudo et détecter un compte suspect
#  Version   : vuln-host (debian:bookworm) — conteneur du lab
#  Exécution : bash scripts/02-socle-technique/06-target_audit_sudo.sh
#              (depuis lab/ ; nécessite `make up`)
#  Statut    : VALIDÉ (2026-08-11)
#
#  Adaptation Docker : la liste officielle (datasets/liste_officielle.txt)
#  est montée dans la cible (/lab/datasets/). Le compte « suspect »
#  svc_backup est créé par images/vuln-host/init.sh.
# ─────────────────────────────────────────────────────────────
set -euo pipefail
cd "$(dirname "$0")/../.."   # → lab/

echo "== Ch06 Ex2 — Audit sudo + compte suspect (cible : vuln-host) =="
fail=0

echo
echo "--- 1. Membres des groupes privilégiés ---"
# NB : le manuel liste `sudo adm ssh` (Ubuntu). Sur Debian (cible du
# lab), le groupe sshd est `_ssh` → on audite `sudo adm` (les deux
# groupes à droits) ; `_ssh` n'a aucun droit d'administration.
out=$(docker compose exec -T vuln-host bash -c "getent group sudo adm")
echo "$out"
echo "$out" | grep -q "sudo" || { echo "✗ groupe sudo absent"; fail=1; }
echo "✓ groupes privilégiés listés"

echo
echo "--- 2. Droits sudo de chaque compte avec shell ---"
out=$(docker compose exec -T vuln-host bash -c '
  for u in $(getent passwd | awk -F: '"'"'$7 ~ /(bash|sh)/ {print $1}'"'"'); do
    echo "== $u =="; sudo -l -U "$u" 2>/dev/null | tail -1
  done')
echo "$out"
echo "$out" | grep -q "== admin ==" || { echo "✗ compte admin non audité"; fail=1; }
echo "✓ droits sudo énumérés par compte"

echo
echo "--- 3. Comparaison avec la liste officielle des comptes ---"
out=$(docker compose exec -T vuln-host bash -c \
  "comm -13 <(sort /lab/datasets/liste_officielle.txt) <(getent passwd | cut -d: -f1 | sort)")
echo "comptes hors liste officielle :"
echo "$out"
echo "$out" | grep -q "svc_backup" || { echo "✗ compte suspect svc_backup non détecté"; fail=1; }
echo "✓ compte suspect détecté (svc_backup)"

echo
if [ "$fail" -eq 0 ]; then
  echo "✅ Ch06 Ex2 : VALIDÉ"
else
  echo "❌ Ch06 Ex2 : ÉCHEC"
  exit 1
fi
