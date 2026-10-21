#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  Chapitre  : 24 — La défense augmentée par l'IA
#  Exercice  : 2 (Intermédiaire) — Concevoir un assistant de tri supervisé
#  Version   : validation par modèle de document
#  Exécution : bash scripts/07-ia-cybersecurite/24-host_assistant_soc.sh
#              (depuis lab/ ; aucun service requis)
#  Statut    : VALIDÉ (2026-08-12)
#
#  Adaptation Docker : l'exercice est un document. Le script génère
#  le cahier des charges de l'assistant SOC (rôle, périmètre, règles
#  de supervision, 3 métriques) et vérifie la structure.
# ─────────────────────────────────────────────────────────────
set -euo pipefail
cd "$(dirname "$0")/../.."   # → lab/

echo "== Ch24 Ex2 — Assistant SOC : cahier des charges (document) =="
fail=0

cat > /tmp/cahier-charges-assistant-soc.md <<'EOF'
# Assistant SOC — cahier des charges (extrait)

## Rôle
- Regrouper, résumer et prioriser les alertes pour l'analyste.
- Répondre aux questions de recherche dans les journaux.

## Périmètre
- Accès en lecture aux journaux du SOC.
- Aucun accès aux systèmes de production, ni action automatique.

## Règles de supervision
1. Toute sortie est une « proposition », non une « décision ».
2. Les actions sensibles exigent une validation humaine.
3. Les réponses sont journalisées et auditées.

## Métriques (3)
1. Faux positifs de l'assistant par semaine.
2. Temps moyen d'investigation par alerte.
3. Taux d'alertes réellement traitées après le tri.
EOF

echo "--- Document généré ---"
cat /tmp/cahier-charges-assistant-soc.md

echo
echo "--- Vérifications ---"
for section in "Rôle" "Périmètre" "Règles de supervision" "Métriques"; do
  grep -q "^## $section" /tmp/cahier-charges-assistant-soc.md && echo "✓ section « $section » présente" || { echo "✗ section « $section » absente"; fail=1; }
done
grep -q "proposition" /tmp/cahier-charges-assistant-soc.md && echo "✓ règle : sortie = proposition, pas décision" || { echo "✗ règle de supervision absente"; fail=1; }
grep -q "validation humaine" /tmp/cahier-charges-assistant-soc.md && echo "✓ règle : validation humaine pour les actions sensibles" || { echo "✗ validation humaine absente"; fail=1; }
grep -q "journalisées" /tmp/cahier-charges-assistant-soc.md && echo "✓ règle : journalisation et audit" || { echo "✗ journalisation absente"; fail=1; }
n=$(grep -cE "^[0-9]\. " /tmp/cahier-charges-assistant-soc.md)
[ "$n" -ge 3 ] && echo "✓ $n métriques de suivi définies" || { echo "✗ métriques insuffisantes ($n)"; fail=1; }
grep -q "Aucun accès aux systèmes de production" /tmp/cahier-charges-assistant-soc.md && echo "✓ périmètre étroit (lecture seule, pas d'action)" || { echo "✗ périmètre absent"; fail=1; }

echo
if [ "$fail" -eq 0 ]; then
  echo "✅ Ch24 Ex2 : VALIDÉ"
else
  echo "❌ Ch24 Ex2 : ÉCHEC"
  exit 1
fi
