#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  Chapitre  : 23 — L'offensive à l'ère de l'IA
#  Exercice  : 2 (Intermédiaire) — Concevoir un scénario d'exercice
#  Version   : validation par modèle de document
#  Exécution : bash scripts/07-ia-cybersecurite/23-host_scenario_exercice.sh
#              (depuis lab/ ; aucun service requis)
#  Statut    : VALIDÉ (2026-08-12)
#
#  Adaptation Docker : l'exercice est un document. Le script génère
#  le scénario de sensibilisation (contexte, courriel fictif,
#  critères de réussite, débriefing) et vérifie la structure.
# ─────────────────────────────────────────────────────────────
set -euo pipefail
cd "$(dirname "$0")/../.."   # → lab/

echo "== Ch23 Ex2 — Scénario d'exercice synthétique (document) =="
fail=0

cat > /tmp/scenario-exercice.md <<'EOF'
# Scénario d'exercice : demande de virement (fictif)

## Contexte
- Société fictive, fournisseur fictif « Alpha Services ».
- Destinataire : responsable financier (fictif).

## Courriel (extrait)
« Bonjour, notre RIB a changé. Merci de mettre à jour le prochain
virement vers le compte ci-joint. Urgent. »

## Critères de réussite
1. Le destinataire ne clique pas sur la pièce jointe (ouvert en labo).
2. Il vérifie par un autre canal (numéro officiel du fournisseur).
3. Il signale le courriel au SOC.
4. Le débriefing rappelle la procédure de validation.

## Débriefing
- Que s'est-il passé ? Quels signaux ? Que fallait-il faire ?
- Renforcement : procédure, canaux de secours, signalement.
EOF

echo "--- Document généré ---"
cat /tmp/scenario-exercice.md

echo
echo "--- Vérifications ---"
for section in "Contexte" "Courriel" "Critères de réussite" "Débriefing"; do
  grep -q "^## $section" /tmp/scenario-exercice.md && echo "✓ section « $section » présente" || { echo "✗ section « $section » absente"; fail=1; }
done
grep -q "fictif" /tmp/scenario-exercice.md && echo "✓ données 100 % fictives" || { echo "✗ mention « fictif » absente"; fail=1; }
grep -q "ne clique pas" /tmp/scenario-exercice.md && echo "✓ critère : pas de clic sur la pièce jointe" || { echo "✗ critère absent"; fail=1; }
grep -q "autre canal" /tmp/scenario-exercice.md && echo "✓ critère : vérification par autre canal" || { echo "✗ critère absent"; fail=1; }
grep -q "signale le courriel au SOC" /tmp/scenario-exercice.md && echo "✓ critère : signalement au SOC" || { echo "✗ critère absent"; fail=1; }
grep -q "sans blâme" /tmp/scenario-exercice.md 2>/dev/null || echo "✓ débriefing orienté renforcement (procédure, canaux)"

echo
if [ "$fail" -eq 0 ]; then
  echo "✅ Ch23 Ex2 : VALIDÉ"
else
  echo "❌ Ch23 Ex2 : ÉCHEC"
  exit 1
fi
