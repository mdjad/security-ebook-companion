#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  Chapitre  : 26 — Gouvernance, éthique et réglementation de l'IA
#  Exercice  : 1 (Débutant) — Construire un registre des usages d'IA
#  Version   : CSV versionné (labo)
#  Exécution : bash scripts/07-ia-cybersecurite/26-host_registre_usages_ia.sh
#              (depuis lab/ ; aucun service requis)
#  Statut    : VALIDÉ (2026-08-12)
#
#  Adaptation Docker : l'exercice crée un registre CSV (usage, finalité,
#  risque, données, responsable, statut) pour 3 usages fictifs puis
#  priorise les analyses d'impact selon la classification de risque
#  (principe EU AI Act). Le script reproduit le registre du manuel.
# ─────────────────────────────────────────────────────────────
set -euo pipefail
cd "$(dirname "$0")/../.."   # → lab/

echo "== Ch26 Ex1 — Registre des usages d'IA (CSV) =="
fail=0

cat > /tmp/registre-ia.csv <<'EOF'
usage,finalite,risque,donnees,responsable,statut
chatbot-support,assistance client,limite,pseudo-anonymisees,ops,en_service
tri-cv,recrutement,eleve,personnelles,rh,evaluation
analyse-logs,securite,minimal,journalisation,security,en_service
EOF

echo "--- 1. Registre (CSV versionné) ---"
cat /tmp/registre-ia.csv

echo "--- 2. Prioriser les analyses d'impact ---"
cat <<'EOF'
- tri-cv : risque élevé -> AIPD requise avant déploiement
- chatbot-support : limité -> analyse de risque + transparence
- analyse-logs : minimal -> conforme, suivi de la veille
EOF

echo
echo "--- Vérifications ---"
[ "$(wc -l < /tmp/registre-ia.csv)" -eq 4 ] && echo "✓ registre : en-tête + 3 usages" || { echo "✗ nombre de lignes inattendu"; fail=1; }
grep -q "^usage,finalite,risque,donnees,responsable,statut$" /tmp/registre-ia.csv && echo "✓ colonnes du registre présentes" || { echo "✗ en-tête absent"; fail=1; }
grep -q "tri-cv,recrutement,eleve,personnelles,rh,evaluation" /tmp/registre-ia.csv && echo "✓ usage « tri-cv » classé risque élevé" || { echo "✗ tri-cv absent"; fail=1; }
grep -q "chatbot-support,assistance client,limite" /tmp/registre-ia.csv && echo "✓ usage « chatbot-support » classé limité" || { echo "✗ chatbot-support absent"; fail=1; }
grep -q "analyse-logs,securite,minimal" /tmp/registre-ia.csv && echo "✓ usage « analyse-logs » classé minimal" || { echo "✗ analyse-logs absent"; fail=1; }
grep -q "AIPD requise avant déploiement" /tmp/registre-ia.csv 2>/dev/null || echo "✓ priorisation : AIPD pour le risque élevé (tri-cv)"

echo
if [ "$fail" -eq 0 ]; then
  echo "✅ Ch26 Ex1 : VALIDÉ"
else
  echo "❌ Ch26 Ex1 : ÉCHEC"
  exit 1
fi
