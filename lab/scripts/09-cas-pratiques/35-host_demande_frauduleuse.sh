#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  Chapitre  : 35 — Cas pratique : réponse à incident à l'ère de l'IA
#  Exercice  : 1 (Débutant) — Simuler la réponse à une demande frauduleuse
#  Version   : document (procédure anti-deepfake)
#  Exécution : bash scripts/09-cas-pratiques/35-host_demande_frauduleuse.sh
#              (depuis lab/)
#  Statut    : VALIDÉ (2026-08-12)
#
#  Adaptation Docker : exercice document → validation par modèle de
#  structure (message fictif, déroulé en 5 étapes, leçon). Aucune
#  personne réelle ; données fictives (ch. 23).
# ─────────────────────────────────────────────────────────────
set -euo pipefail
cd "$(dirname "$0")/../.."   # → lab/

echo "== Ch35 Ex1 — Demande frauduleuse (fictive) =="
fail=0

DOC=/tmp/demande-frauduleuse.md
cat > "$DOC" <<'EOF'
# Exercice : demande frauduleuse (fictive)

## Message reçu (fictif)
« Bonjour, situation urgente et confidentielle : merci de transférer
immédiatement 15 000 € sur le compte ci-joint. »

## Déroulé (procédure)
1. Aucune transaction effectuée.
2. Vérification par le canal officiel (numéro de la ligne fixe du
   dirigeant, préalablement enregistré) -> demande non confirmée.
3. Signalement au SOC ; gel du processus.
4. Preuves préservées : message, métadonnées, horodatage (ch. 16, 19).
5. Sensibilisation et renforcement de la double validation.

## Leçon
Une demande « urgente et secrète » sur un canal unique = signal d'alerte.
EOF

echo "--- Document généré ---"
cat "$DOC"

echo
echo "--- Vérifications ---"
grep -q "^## Message reçu" "$DOC" && echo "✓ message fictif documenté" || { echo "✗ message absent"; fail=1; }
grep -q "Aucune transaction effectuée" "$DOC" && echo "✓ aucune transaction (règle d'or)" || { echo "✗ règle d'or absente"; fail=1; }
grep -q "canal officiel" "$DOC" && echo "✓ vérification par canal distinct" || { echo "✗ canal distinct absent"; fail=1; }
grep -q "Signalement au SOC" "$DOC" && echo "✓ signalement au SOC" || { echo "✗ signalement absent"; fail=1; }
grep -q "Preuves préservées" "$DOC" && echo "✓ preuves préservées" || { echo "✗ preuves absentes"; fail=1; }
grep -q "^## Leçon" "$DOC" && echo "✓ leçon documentée" || { echo "✗ leçon absente"; fail=1; }

echo
if [ "$fail" -eq 0 ]; then
  echo "✅ Ch35 Ex1 : VALIDÉ"
else
  echo "❌ Ch35 Ex1 : ÉCHEC"
  exit 1
fi
