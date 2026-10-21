#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  Partie 07 — La cybersécurité à l'ère de l'IA (Ch22-26)
#  Exécution : bash scripts/07-ia-cybersecurite/validate.sh
#  Statut    : VALIDÉ (2026-08-12)
# ─────────────────────────────────────────────────────────────
set -uo pipefail
cd "$(dirname "$0")"

echo "== Validation Partie 07 (Ch22-26) =="
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
  echo "✅ Partie 07 : toutes les validations passent"
else
  echo "❌ Partie 07 : au moins un script en échec"
  exit 1
fi
