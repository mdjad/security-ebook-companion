#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  Chapitre  : 26 — Gouvernance, éthique et réglementation de l'IA
#  Exercice  : 3 (Confirmé) — Définir un plan de gouvernance IA
#  Version   : validation par modèle de document
#  Exécution : bash scripts/07-ia-cybersecurite/26-host_gouvernance_ia.sh
#              (depuis lab/ ; aucun service requis)
#  Statut    : VALIDÉ (2026-08-12)
#
#  Adaptation Docker : l'exercice est un document. Le script génère
#  le plan de gouvernance IA (registre, responsabilités, politiques,
#  approbation, supervision, incidents, veille) + feuille de route
#  datée, et vérifie la structure + les cadres (AI Act, RGPD, NIST,
#  ISO 42001).
# ─────────────────────────────────────────────────────────────
set -euo pipefail
cd "$(dirname "$0")/../.."   # → lab/

echo "== Ch26 Ex3 — Plan de gouvernance IA (document) =="
fail=0

cat > /tmp/plan-gouvernance-ia.md <<'EOF'
# Plan de gouvernance IA (fictif)

## 1. Registre
- Inventaire de tous les usages, classification des risques, mise à jour continue.

## 2. Responsabilités
- Comité gouvernance IA (direction, RSSI, DPO, métiers).
- Propriétaire par système ; DPO pour les données.

## 3. Politiques
- Usage de l'IA (types autorisés), données (RGPD), fournisseurs (ch. 29),
  développement sécurisé (ch. 25).

## 4. Processus d'approbation
- Toute mise en service : analyse de risque/AIPD, registre, supervision,
  journalisation, formation.

## 5. Supervision humaine
- Actions sensibles validées par un humain ; procédures de secours.

## 6. Incidents et plaintes
- Intégrés à la gestion d'incidents (ch. 19) ; tracés.

## 7. Veille et revues
- Veille AI Act/NIST/ISO/RGPD ; revue annuelle du plan.

## Feuille de route
| Phase | Actions | Échéance |
|---|---|---|
| 1 | Registre + classification | 30 j |
| 2 | Politiques + responsabilités | 60 j |
| 3 | AIPD + contrôles techniques | 90 j |
| 4 | Veille, audits, revues | continu |
EOF

echo "--- Document généré ---"
cat /tmp/plan-gouvernance-ia.md

echo
echo "--- Vérifications ---"
for section in "1. Registre" "2. Responsabilités" "3. Politiques" "4. Processus d'approbation" "5. Supervision humaine" "6. Incidents et plaintes" "7. Veille et revues" "Feuille de route"; do
  grep -q "^## $section" /tmp/plan-gouvernance-ia.md && echo "✓ section « $section » présente" || { echo "✗ section « $section » absente"; fail=1; }
done
grep -q "Comité gouvernance IA" /tmp/plan-gouvernance-ia.md && echo "✓ responsabilités : comité de gouvernance" || { echo "✗ comité absent"; fail=1; }
grep -q "AIPD" /tmp/plan-gouvernance-ia.md && echo "✓ approbation : AIPD avant mise en service" || { echo "✗ AIPD absent"; fail=1; }
grep -q "gestion d'incidents" /tmp/plan-gouvernance-ia.md && echo "✓ incidents intégrés (ch. 19)" || { echo "✗ incidents absents"; fail=1; }
grep -q "AI Act" /tmp/plan-gouvernance-ia.md && echo "✓ veille : EU AI Act" || { echo "✗ AI Act absent"; fail=1; }
grep -q "| 1 | Registre + classification | 30 j |" /tmp/plan-gouvernance-ia.md && echo "✓ feuille de route datée (30 j)" || { echo "✗ feuille de route absente"; fail=1; }

echo
if [ "$fail" -eq 0 ]; then
  echo "✅ Ch26 Ex3 : VALIDÉ"
else
  echo "❌ Ch26 Ex3 : ÉCHEC"
  exit 1
fi
