#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  Chapitre  : 39 — Fiches mémo de révision
#  Exercice  : 2 (Intermédiaire) — Réviser avec les fiches
#  Version   : document (sélection + relue sans écran + compléments)
#  Exécution : bash scripts/10-erreurs-commandes-memo/39-host_reviser_fiches.sh
#              (depuis lab/)
#  Statut    : VALIDÉ (2026-08-12)
#
#  Adaptation Docker : exercice document → validation par modèle de
#  structure (sélection de fiches, relue sans écran, compléments).
#  Reprend la correction du manuel (examen 43).
# ─────────────────────────────────────────────────────────────
set -euo pipefail
cd "$(dirname "$0")/../.."   # → lab/

echo "== Ch39 Ex2 — Réviser avec les fiches =="
fail=0

DOC=/tmp/revision-fiches.md
cat > "$DOC" <<'EOF'
# Sélection pour l'examen 43
Fiches : 7 (crypto), 10 (IA), 11 (défense), 12 (gouvernance)

# Relue sans écran
- ce qui sort : modèle CIA, 3 rôles IA, cycle d'incident
- ce qui manque : chiffrement de la base de données -> ch. 13

# Compléments
- relire ch. 13 (données) et ch. 18 (détection)
- refaire un QCM de l'examen 43 pour valider
EOF

echo "--- Document généré ---"
cat "$DOC"

echo
echo "--- Vérifications ---"
grep -q "^# Sélection" "$DOC" && echo "✓ sélection de fiches" || { echo "✗ sélection absente"; fail=1; }
grep -q "Fiches : 7" "$DOC" && echo "✓ fiches listées" || { echo "✗ fiches absentes"; fail=1; }
grep -q "^# Relue sans écran" "$DOC" && echo "✓ relue sans écran" || { echo "✗ relue absente"; fail=1; }
grep -q "ce qui manque" "$DOC" && echo "✓ lacunes identifiées" || { echo "✗ lacunes absentes"; fail=1; }
grep -q "^# Compléments" "$DOC" && echo "✓ compléments" || { echo "✗ compléments absents"; fail=1; }
grep -q "ch. 13" "$DOC" && echo "✓ compléments reliés aux chapitres" || { echo "✗ références absentes"; fail=1; }

echo
if [ "$fail" -eq 0 ]; then
  echo "✅ Ch39 Ex2 : VALIDÉ"
else
  echo "❌ Ch39 Ex2 : ÉCHEC"
  exit 1
fi
