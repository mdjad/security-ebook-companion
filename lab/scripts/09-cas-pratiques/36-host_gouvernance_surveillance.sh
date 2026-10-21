#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  Chapitre  : 36 — Cas pratique : sécuriser un projet d'IA/LLM
#  Exercice  : 3 (Confirmé) — Gouvernance complète et plan de surveillance
#  Version   : document (dossier de gouvernance)
#  Exécution : bash scripts/09-cas-pratiques/36-host_gouvernance_surveillance.sh
#              (depuis lab/)
#  Statut    : VALIDÉ (2026-08-12)
#
#  Adaptation Docker : exercice document → validation par modèle de
#  structure (registre, AIPD, responsabilités, politique, plan de
#  surveillance, revues). Reprend la correction du manuel
#  (ch. 4, 19, 24, 26, 34).
# ─────────────────────────────────────────────────────────────
set -euo pipefail
cd "$(dirname "$0")/../.."   # → lab/

echo "== Ch36 Ex3 — Gouvernance et surveillance (tri de CV) =="
fail=0

DOC=/tmp/gouvernance-surveillance-ia.md
cat > "$DOC" <<'EOF'
# Gouvernance et surveillance — tri de CV (fictif)

## Registre
- Usage : tri de CV ; risque élevé ; responsable : RH ; AIPD : oui.

## AIPD (synthèse)
- Traitement : présélection de candidatures (données personnelles).
- Risques : biais, décision erronée, fuite.
- Mesures : tests de biais, minimisation, transparence, supervision
  humaine, journalisation, procédure de recours.

## Responsabilités
- Propriétaire : RH ; DPO ; RSSI ; développeur (garde-fous).

## Politique d'usage
- Modèles autorisés ; fournisseurs évalués (ch. 29) ; pas de secrets ;
  supervision des décisions.

## Plan de surveillance
- Journaux des flux dans le SIEM (ch. 18, 34).
- Alertes : fuites de secrets, volumes anormaux, échecs de garde-fous.
- Playbook d'incident IA (ch. 19, 35).
- Métriques : incidents, faux positifs, respect des garde-fous.

## Revues
- Mensuelle (métriques) ; annuelle (AIPD, politique, veille ch. 26).
EOF

echo "--- Document généré ---"
cat "$DOC"

echo
echo "--- Vérifications ---"
grep -q "^## Registre" "$DOC" && echo "✓ registre" || { echo "✗ registre absent"; fail=1; }
grep -q "^## AIPD" "$DOC" && echo "✓ AIPD synthétique" || { echo "✗ AIPD absent"; fail=1; }
grep -q "^## Responsabilités" "$DOC" && echo "✓ responsabilités" || { echo "✗ responsabilités absentes"; fail=1; }
grep -q "^## Politique d'usage" "$DOC" && echo "✓ politique d'usage" || { echo "✗ politique absente"; fail=1; }
grep -q "^## Plan de surveillance" "$DOC" && echo "✓ plan de surveillance" || { echo "✗ plan absent"; fail=1; }
grep -q "Playbook d'incident IA" "$DOC" && echo "✓ playbook d'incident IA" || { echo "✗ playbook absent"; fail=1; }
grep -q "^## Revues" "$DOC" && echo "✓ revues (mensuelle/annuelle)" || { echo "✗ revues absentes"; fail=1; }

echo
if [ "$fail" -eq 0 ]; then
  echo "✅ Ch36 Ex3 : VALIDÉ"
else
  echo "❌ Ch36 Ex3 : ÉCHEC"
  exit 1
fi
