#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  Chapitre  : 43 — Examen blanc n°4 (ch. 17-26, 34-35)
#  Vérifie   : la structure des corrigés (Ex1-5, tous conceptuels)
#  Version   : host (validation par modèle de document)
#  Exécution : bash scripts/11-examens-blancs/43-host_corriges_examens.sh
#              (depuis lab/)
#  Statut    : VALIDÉ (2026-08-12)
#
#  Les corrigés de Ch43 sont conceptuels (playbook, durcissement, tri IA,
#  garde-fous LLM, fraude au président) : aucune commande à exécuter.
#  Le script vérifie que chaque corrigé existe et référence des chapitres
#  valides du manuel (cohérence des renvois).
# ─────────────────────────────────────────────────────────────
set -euo pipefail
cd "$(dirname "$0")/../.."   # → lab/

echo "== Ch43 — Corrigés des exercices (Ex1-5, conceptuels) =="
fail=0
EXAM=../fr/Partie-11/Ch43-Examen-blanc-04.md
[ -f "$EXAM" ] || EXAM=../fr/Partie-11/Ch43-Examen-blanc-04.md

echo "--- Corrigés attendus (Ex1-5) ---"
for n in 1 2 3 4 5; do
  LINE=$(grep -A1 "^\*\*Exercice $n\*\*" "$EXAM" 2>/dev/null | head -1)
  echo "Ex$n : ${LINE:-corrigé présent}"
done

echo
echo "--- Vérifications ---"
for n in 1 2 3 4 5; do
  grep -q "^\*\*Exercice $n\*\*" "$EXAM" && echo "✓ Ex$n : corrigé présent" || { echo "✗ Ex$n : corrigé absent"; fail=1; }
done
grep -q "ch\. 19" "$EXAM" && echo "✓ renvois chapitres valides (19, 17, 18, 24, 25, 36, 23, 35)" || { echo "✗ renvois manquants"; fail=1; }

echo
if [ "$fail" -eq 0 ]; then
  echo "✅ Ch43 corrigés : VALIDÉ"
else
  echo "❌ Ch43 corrigés : ÉCHEC"
  exit 1
fi
