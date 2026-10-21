#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  Chapitre  : 25 — Sécuriser les systèmes d'IA
#  Exercice  : 1 (Débutant) — Identifier les points de fuite d'un flux d'IA
#  Version   : validation par modèle de document
#  Exécution : bash scripts/07-ia-cybersecurite/25-host_points_fuite_ia.sh
#              (depuis lab/ ; aucun service requis)
#  Statut    : VALIDÉ (2026-08-12)
#
#  Adaptation Docker : l'exercice est un document. Le script génère
#  la carte des points de fuite d'un assistant RAG (point de fuite,
#  données, contrôle) et vérifie la structure + la conclusion.
# ─────────────────────────────────────────────────────────────
set -euo pipefail
cd "$(dirname "$0")/../.."   # → lab/

echo "== Ch25 Ex1 — Points de fuite d'un flux d'IA (document) =="
fail=0

cat > /tmp/points-fuite-ia.md <<'EOF'
# Points de fuite d'un assistant RAG (fictif)

| Point de fuite | Données concernées | Contrôle |
|---|---|---|
| Prompt vers l'API | contenu de la requête | pas de secrets, minimisation |
| Journaux de l'API | questions/réponses | rotation, rétention (ch. 18) |
| Documents RAG | documents sensibles | contrôle des sources, ACL |
| Réponses à l'utilisateur | résumés | validation des sorties |
| Outils/agents | actions | moindre privilège, validation |

# Conclusion
- Minimiser les données dans les prompts.
- Journaliser et surveiller les flux (ch. 18).
- Contrôler les sources et les accès (moindre privilège).
EOF

echo "--- Document généré ---"
cat /tmp/points-fuite-ia.md

echo
echo "--- Vérifications ---"
grep -q "| Point de fuite | Données concernées | Contrôle |" /tmp/points-fuite-ia.md && echo "✓ tableau des points de fuite présent" || { echo "✗ tableau absent"; fail=1; }
for pf in "Prompt vers l'API" "Journaux de l'API" "Documents RAG" "Réponses à l'utilisateur" "Outils/agents"; do
  grep -q "$pf" /tmp/points-fuite-ia.md && echo "✓ point de fuite « $pf » présent" || { echo "✗ point de fuite « $pf » absent"; fail=1; }
done
grep -q "minimisation" /tmp/points-fuite-ia.md && echo "✓ contrôle : minimisation des données" || { echo "✗ minimisation absente"; fail=1; }
grep -q "moindre privilège" /tmp/points-fuite-ia.md && echo "✓ contrôle : moindre privilège" || { echo "✗ moindre privilège absent"; fail=1; }
grep -q "^# Conclusion" /tmp/points-fuite-ia.md && echo "✓ conclusion présente" || { echo "✗ conclusion absente"; fail=1; }

echo
if [ "$fail" -eq 0 ]; then
  echo "✅ Ch25 Ex1 : VALIDÉ"
else
  echo "❌ Ch25 Ex1 : ÉCHEC"
  exit 1
fi
