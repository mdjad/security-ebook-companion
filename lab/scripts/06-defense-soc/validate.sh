#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  Partie 06 — Défense, durcissement et gestion des incidents (Ch17-21)
#  Exécution : bash scripts/06-defense-soc/validate.sh
#  Statut    : VALIDÉ (2026-08-12)
# ─────────────────────────────────────────────────────────────
set -uo pipefail
cd "$(dirname "$0")"

echo "== Validation Partie 06 (Ch17-21) =="
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
  echo "✅ Partie 06 : toutes les validations passent"
else
  echo "❌ Partie 06 : au moins un script en échec"
  exit 1
fi
