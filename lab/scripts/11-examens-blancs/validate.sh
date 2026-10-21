#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  Partie 11 — Examens blancs (Ch40-44) : validation des corrigés
#  Exécution : bash scripts/11-examens-blancs/validate.sh (depuis lab/)
#  Statut    : VALIDÉ (2026-08-12)
#
#  Vérifie que les commandes des corrigés des 5 examens blancs
#  correspondent à la réalité opérationnelle (testées dans le lab).
# ─────────────────────────────────────────────────────────────
set -euo pipefail
cd "$(dirname "$0")"

echo "== Validation Partie 11 (Ch40-44) =="
fail=0
count=0

for script in *.sh; do
  [ "$script" = "validate.sh" ] && continue
  count=$((count + 1))
  echo
  echo "── $script ──"
  if ! grep -q "Statut    : VALIDÉ" "$script"; then
    echo "✗ $script : en-tête sans « Statut : VALIDÉ »"
    fail=1
    continue
  fi
  if ! bash "$script"; then
    echo "✗ $script : échec d'exécution"
    fail=1
  fi
done

echo
echo "── Bilan ──"
echo "scripts exécutés : $count"
if [ "$fail" -eq 0 ]; then
  echo "✅ Partie 11 : toutes les corrections validées"
else
  echo "❌ Partie 11 : $fail script(s) en échec"
  exit 1
fi
