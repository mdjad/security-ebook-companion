#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  Chapitre  : 26 — Gouvernance, éthique et réglementation de l'IA
#  Exercice  : 2 (Intermédiaire) — Mener une analyse d'impact (AIPD)
#  Version   : validation par modèle de document
#  Exécution : bash scripts/07-ia-cybersecurite/26-host_aipd.sh
#              (depuis lab/ ; aucun service requis)
#  Statut    : VALIDÉ (2026-08-12)
#
#  Adaptation Docker : l'exercice est un document. Le script génère
#  l'AIPD du tri de CV automatisé (usage fictif du registre) et
#  vérifie la structure (traitement, données, risques, mesures,
#  supervision, responsables) + les principes RGPD/AI Act.
# ─────────────────────────────────────────────────────────────
set -euo pipefail
cd "$(dirname "$0")/../.."   # → lab/

echo "== Ch26 Ex2 — AIPD : tri de CV automatisé (document) =="
fail=0

cat > /tmp/aipd-tri-cv.md <<'EOF'
# AIPD — Tri de CV automatisé (fictif)

## Traitement
- Finalité : présélection des candidatures.
- Base légale : intérêt légitime (documenté) / consentement si requis.

## Données
- CV, compétences, expériences (minimisation).

## Risques pour les personnes
- Décision biaisée, exclusion injustifiée, erreur de tri.

## Mesures
- Qualité et revue des données d'entraînement (ch. 25).
- Test des biais ; transparence envers les candidats.
- Journalisation et revue des décisions.
- Supervision humaine sur les décisions sensibles.

## Supervision
- Un recruteur valide toute décision de tri avant action.
- Procédure de recours pour les candidats.

## Responsables
- Propriétaire du système (RH) ; DPO ; RSSI.
- Revue annuelle.
EOF

echo "--- Document généré ---"
cat /tmp/aipd-tri-cv.md

echo
echo "--- Vérifications ---"
for section in "Traitement" "Données" "Risques pour les personnes" "Mesures" "Supervision" "Responsables"; do
  grep -q "^## $section" /tmp/aipd-tri-cv.md && echo "✓ section « $section » présente" || { echo "✗ section « $section » absente"; fail=1; }
done
grep -q "minimisation" /tmp/aipd-tri-cv.md && echo "✓ principe : minimisation des données" || { echo "✗ minimisation absente"; fail=1; }
grep -q "Décision biaisée" /tmp/aipd-tri-cv.md && echo "✓ risques pour les personnes identifiés" || { echo "✗ risques absents"; fail=1; }
grep -q "Supervision humaine" /tmp/aipd-tri-cv.md && echo "✓ mesure : supervision humaine" || { echo "✗ supervision absente"; fail=1; }
grep -q "recours" /tmp/aipd-tri-cv.md && echo "✓ procédure de recours (RGPD)" || { echo "✗ recours absent"; fail=1; }
grep -q "DPO" /tmp/aipd-tri-cv.md && echo "✓ responsables désignés (DPO)" || { echo "✗ DPO absent"; fail=1; }

echo
if [ "$fail" -eq 0 ]; then
  echo "✅ Ch26 Ex2 : VALIDÉ"
else
  echo "❌ Ch26 Ex2 : ÉCHEC"
  exit 1
fi
