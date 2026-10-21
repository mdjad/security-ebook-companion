#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  Chapitre  : 34 — Cas pratique : déployer un SOC augmenté par l'IA
#  Exercice  : 3 (Confirmé) — Ajouter une assistance IA supervisée et mesurer
#  Version   : document (cahier des charges assistant SOC)
#  Exécution : bash scripts/09-cas-pratiques/34-host_assistant_soc_supervise.sh
#              (depuis lab/)
#  Statut    : VALIDÉ (2026-08-12)
#
#  Adaptation Docker : exercice document → validation par modèle de
#  structure (rôle, règles de supervision, métriques avant/après,
#  décision). Reprend la correction du manuel (ch. 24).
# ─────────────────────────────────────────────────────────────
set -euo pipefail
cd "$(dirname "$0")/../.."   # → lab/

echo "== Ch34 Ex3 — Assistance IA supervisée (SOC) =="
fail=0

DOC=/tmp/assistant-soc-supervise.md
cat > "$DOC" <<'EOF'
# Assistance IA supervisée (ch. 24)

## Rôle
- Regrouper et résumer les alertes pour l'analyste.
- Prioriser (criticité, contexte).

## Règles de supervision
1. Toute sortie est une « proposition ».
2. Actions sensibles : validation humaine.
3. Requêtes et réponses journalisées.

## Métriques avant/après
| Indicateur | Avant | Après |
|---|---|---|
| Alertes à traiter / jour | 100 | 20 regroupées |
| Temps de tri / alerte | 8 min | 4 min |
| Faux positifs / jour | 15 | 18 (dont 3 IA) |

## Décision
- L'assistant réduit le tri, mais ses faux positifs sont suivis
  et les règles ajustées chaque semaine.
EOF

echo "--- Document généré ---"
cat "$DOC"

echo
echo "--- Vérifications ---"
grep -q "^## Rôle" "$DOC" && echo "✓ rôle défini" || { echo "✗ rôle absent"; fail=1; }
grep -q "^## Règles de supervision" "$DOC" && echo "✓ règles de supervision" || { echo "✗ supervision absente"; fail=1; }
grep -q "validation humaine" "$DOC" && echo "✓ l'assistant ne décide jamais seul" || { echo "✗ validation humaine absente"; fail=1; }
grep -q "^## Métriques avant/après" "$DOC" && echo "✓ métriques avant/après" || { echo "✗ métriques absentes"; fail=1; }
grep -q "Faux positifs" "$DOC" && echo "✓ faux positifs mesurés" || { echo "✗ faux positifs absents"; fail=1; }
grep -q "^## Décision" "$DOC" && echo "✓ décision documentée" || { echo "✗ décision absente"; fail=1; }

echo
if [ "$fail" -eq 0 ]; then
  echo "✅ Ch34 Ex3 : VALIDÉ"
else
  echo "❌ Ch34 Ex3 : ÉCHEC"
  exit 1
fi
