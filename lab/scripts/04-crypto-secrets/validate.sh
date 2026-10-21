#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  Partie 04 — Cryptographie et protection des données (Ch12-13)
#  Exécution : bash scripts/04-crypto-secrets/validate.sh
#  Statut    : VALIDÉ (2026-08-11)
# ─────────────────────────────────────────────────────────────
set -uo pipefail
cd "$(dirname "$0")"

echo "== Validation Partie 04 (Ch12-13) =="
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
  echo "✅ Partie 04 : toutes les validations passent"
else
  echo "❌ Partie 04 : au moins un script en échec"
  exit 1
fi
