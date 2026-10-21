#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  Validation de la Partie 10 — Erreurs, commandes et fiches mémo
#  (Ch37-39). Exécute tous les scripts du dossier et échoue si un
#  script n'est pas marqué « Statut : VALIDÉ ».
# ─────────────────────────────────────────────────────────────
set -euo pipefail
cd "$(dirname "$0")"

echo "== Validation Partie 10 (Ch37-39) =="
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
  echo "✅ Partie 10 : toutes les validations passent"
else
  echo "❌ Partie 10 : $fail script(s) en échec"
  exit 1
fi
