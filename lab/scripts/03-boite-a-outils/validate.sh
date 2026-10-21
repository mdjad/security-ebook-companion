#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  Partie 03 — Boîte à outils (Ch09-11) : validation
#  Exécution : bash scripts/03-boite-a-outils/validate.sh
#  Statut    : VALIDÉ (2026-08-11)
# ─────────────────────────────────────────────────────────────
set -uo pipefail
cd "$(dirname "$0")"

echo "== Validation Partie 03 (Ch09-11) =="
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
  echo "✅ Partie 03 : toutes les validations passent"
else
  echo "❌ Partie 03 : au moins un script en échec"
  exit 1
fi
