#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  Chapitre  : 22 — Comprendre l'IA en cybersécurité
#  Exercice  : 1 (Débutant) — Classer les usages de l'IA
#  Version   : validation par modèle de document
#  Exécution : bash scripts/07-ia-cybersecurite/22-host_classifier_usages_ia.sh
#              (depuis lab/ ; aucun service requis)
#  Statut    : VALIDÉ (2026-08-12)
#
#  Adaptation Docker : l'exercice est un document. Le script génère
#  la classification (arme / bouclier / cible × technologie) des
#  5 usages du manuel et vérifie chaque réponse attendue.
# ─────────────────────────────────────────────────────────────
set -euo pipefail
cd "$(dirname "$0")/../.."   # → lab/

echo "== Ch22 Ex1 — Classer les usages de l'IA (document) =="
fail=0

cat > /tmp/classement-usages-ia.md <<'EOF'
# Classification des usages de l'IA (fictif)

| # | Usage | Rôle principal | Technologie | Justification |
|---|---|---|---|---|
| 1 | Filtre anti-phishing | Bouclier | ML de détection | Protège l'organisation en classant les courriels malveillants |
| 2 | Campagne de phishing générée | Arme | GenAI | L'attaquant génère des courriels crédibles pour tromper |
| 3 | Assistant de résumé d'alertes SOC | Bouclier | GenAI d'assistance | Accélère l'analyse des alertes (supervision humaine) |
| 4 | Chatbot de support (fuite après injection) | Cible | Système d'IA | Le chatbot est attaqué (injection de prompt) pour fuir des données |
| 5 | Reconnaissance faciale | Bouclier ou cible | ML de détection | Protège (vérification) mais peut être attaqué (usurpation, biais) |

## Conclusion
- La plupart des usages relèvent d'un rôle principal, certains sont ambivalents.
- Établir un registre des usages IA et associer chaque usage à ses risques.
EOF

echo "--- Document généré ---"
cat /tmp/classement-usages-ia.md

echo
echo "--- Vérifications ---"
for i in 1 2 3 4 5; do
  grep -q "| $i |" /tmp/classement-usages-ia.md && echo "✓ usage $i classé" || { echo "✗ usage $i absent"; fail=1; }
done
grep -q "| 1 |.*Bouclier.*ML de détection" /tmp/classement-usages-ia.md && echo "✓ usage 1 : Bouclier (ML de détection)" || { echo "✗ usage 1 mal classé"; fail=1; }
grep -q "| 2 |.*Arme.*GenAI" /tmp/classement-usages-ia.md && echo "✓ usage 2 : Arme (GenAI)" || { echo "✗ usage 2 mal classé"; fail=1; }
grep -q "| 3 |.*Bouclier.*GenAI" /tmp/classement-usages-ia.md && echo "✓ usage 3 : Bouclier (GenAI d'assistance)" || { echo "✗ usage 3 mal classé"; fail=1; }
grep -q "| 4 |.*Cible.*Système d'IA" /tmp/classement-usages-ia.md && echo "✓ usage 4 : Cible (injection de prompt)" || { echo "✗ usage 4 mal classé"; fail=1; }
grep -q "| 5 |.*Bouclier ou cible" /tmp/classement-usages-ia.md && echo "✓ usage 5 : Bouclier ou cible (ambivalent)" || { echo "✗ usage 5 mal classé"; fail=1; }
grep -q "registre des usages" /tmp/classement-usages-ia.md && echo "✓ conclusion : registre des usages recommandé" || { echo "✗ conclusion absente"; fail=1; }

echo
if [ "$fail" -eq 0 ]; then
  echo "✅ Ch22 Ex1 : VALIDÉ"
else
  echo "❌ Ch22 Ex1 : ÉCHEC"
  exit 1
fi
