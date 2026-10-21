#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  Chapitre  : 25 — Sécuriser les systèmes d'IA
#  Exercice  : 3 (Confirmé) — Conduire une revue de sécurité d'un système d'IA
#  Version   : validation par modèle de document
#  Exécution : bash scripts/07-ia-cybersecurite/25-host_revue_securite_ia.sh
#              (depuis lab/ ; aucun service requis)
#  Statut    : VALIDÉ (2026-08-12)
#
#  Adaptation Docker : l'exercice est un document. Le script génère
#  la revue de sécurité d'un projet LLM fictif selon la checklist
#  OWASP Top 10 for LLM (injection, fuite, chaîne d'approvisionnement,
#  extraction, agents) et vérifie structure + priorités datées.
# ─────────────────────────────────────────────────────────────
set -euo pipefail
cd "$(dirname "$0")/../.."   # → lab/

echo "== Ch25 Ex3 — Revue de sécurité d'un système d'IA (document) =="
fail=0

cat > /tmp/revue-securite-ia.md <<'EOF'
# Revue de sécurité — projet LLM (fictif)

## Checklist (extraits OWASP Top 10 for LLM)
1. Prompt injection : entrées traitées comme données ? -> Écart : documents RAG
   Action : marquer les données, validation des sorties (15 j).
2. Fuite d'informations : secrets dans les prompts ? -> Écart : un prompt d'exemple
   Action : retirer, rotation (ch. 13), politique (30 j).
3. Chaîne d'approvisionnement : modèle/dépendances audités ? -> À confirmer
   Action : SBOM + scan (ch. 30) (45 j).
4. Extraction : quotas et monitoring ? -> Écart : aucun quota
   Action : quotas + alertes SIEM (ch. 18) (30 j).
5. Agents : moindre privilège + validation ? -> À confirmer
   Action : revue des accès, validation des actions sensibles (30 j).

## Priorités
1. Secrets hors des prompts (immédiat)
2. Séparation instruction/données (15 j)
3. Quotas + monitoring (30 j)
4. SBOM + scan (45 j)
EOF

echo "--- Document généré ---"
cat /tmp/revue-securite-ia.md

echo
echo "--- Vérifications ---"
grep -q "OWASP Top 10 for LLM" /tmp/revue-securite-ia.md && echo "✓ cadre : OWASP Top 10 for LLM" || { echo "✗ cadre absent"; fail=1; }
for item in "Prompt injection" "Fuite d'informations" "Chaîne d'approvisionnement" "Extraction" "Agents"; do
  grep -q "$item" /tmp/revue-securite-ia.md && echo "✓ point de revue « $item » présent" || { echo "✗ point « $item » absent"; fail=1; }
done
grep -q "Écart" /tmp/revue-securite-ia.md && echo "✓ écarts identifiés" || { echo "✗ aucun écart"; fail=1; }
grep -q "15 j" /tmp/revue-securite-ia.md && echo "✓ actions datées (15 j)" || { echo "✗ échéance absente"; fail=1; }
grep -q "SBOM" /tmp/revue-securite-ia.md && echo "✓ chaîne d'approvisionnement : SBOM + scan" || { echo "✗ SBOM absent"; fail=1; }
grep -q "^## Priorités" /tmp/revue-securite-ia.md && echo "✓ priorités présentes" || { echo "✗ priorités absentes"; fail=1; }

echo
if [ "$fail" -eq 0 ]; then
  echo "✅ Ch25 Ex3 : VALIDÉ"
else
  echo "❌ Ch25 Ex3 : ÉCHEC"
  exit 1
fi
