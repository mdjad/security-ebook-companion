#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  Chapitre  : 36 — Cas pratique : sécuriser un projet d'IA/LLM
#  Exercice  : 1 (Débutant) — Classifier un cas d'usage d'IA
#  Version   : document (grille de classification)
#  Exécution : bash scripts/09-cas-pratiques/36-host_classifier_usages_ia.sh
#              (depuis lab/)
#  Statut    : VALIDÉ (2026-08-12)
#
#  Adaptation Docker : exercice document → validation par modèle de
#  structure (tableau 3 usages + contrôles associés). Reprend la
#  correction du manuel (ch. 13, 25, 26).
# ─────────────────────────────────────────────────────────────
set -euo pipefail
cd "$(dirname "$0")/../.."   # → lab/

echo "== Ch36 Ex1 — Classification des usages d'IA =="
fail=0

DOC=/tmp/classification-usages-ia.md
cat > "$DOC" <<'EOF'
# Classification des usages d'IA (fictif)

| Usage | Données | Impact | Risque AI Act | AIPD |
|---|---|---|---|---|
| Chatbot support | internes | moyen | limité | non |
| Tri de CV | personnelles | élevé | élevé | oui |
| Analyse docs publics | publiques | faible | minimal | non |

## Contrôles associés
- Chatbot support : flux minimisés, garde-fous, surveillance (ch. 25, 18).
- Tri de CV : AIPD, supervision humaine, transparence, tests de biais (ch. 26).
- Docs publics : usage minimal, conformité, suivi de la veille.
EOF

echo "--- Document généré ---"
cat "$DOC"

echo
echo "--- Vérifications ---"
grep -q "Chatbot support" "$DOC" && echo "✓ usage 1 : chatbot support" || { echo "✗ chatbot absent"; fail=1; }
grep -q "Tri de CV" "$DOC" && echo "✓ usage 2 : tri de CV" || { echo "✗ tri de CV absent"; fail=1; }
grep -q "Analyse docs publics" "$DOC" && echo "✓ usage 3 : analyse docs publics" || { echo "✗ docs publics absents"; fail=1; }
grep -q "Risque AI Act" "$DOC" && echo "✓ colonne risque AI Act" || { echo "✗ risque AI Act absent"; fail=1; }
grep -q "AIPD" "$DOC" && echo "✓ colonne AIPD" || { echo "✗ AIPD absent"; fail=1; }
grep -q "^## Contrôles associés" "$DOC" && echo "✓ contrôles associés" || { echo "✗ contrôles absents"; fail=1; }

echo
if [ "$fail" -eq 0 ]; then
  echo "✅ Ch36 Ex1 : VALIDÉ"
else
  echo "❌ Ch36 Ex1 : ÉCHEC"
  exit 1
fi
