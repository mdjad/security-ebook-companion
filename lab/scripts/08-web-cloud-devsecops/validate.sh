#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  Partie 08 — Sécurité applicative, web, cloud et DevOps (Ch27-30)
#  Exécution : bash scripts/08-web-cloud-devsecops/validate.sh
#  Statut    : VALIDÉ (2026-08-12)
# ─────────────────────────────────────────────────────────────
set -uo pipefail
cd "$(dirname "$0")"

echo "== Validation Partie 08 (Ch27-30) =="
fail=0

for s in *.sh; do
  [ "$s" = "validate.sh" ] && continue
  echo
  echo "──────────────────────────────────────────────"
  echo "▶ $s"
  echo "──────────────────────────────────────────────"
  if bash "$s"; then
    echo "OK: $s"
  else
    echo "FAIL: $s"
    fail=1
  fi
done

echo
if [ "$fail" -eq 0 ]; then
  echo "✅ Partie 08 : toutes les validations passent"
else
  echo "❌ Partie 08 : au moins un script en échec"
  exit 1
fi
