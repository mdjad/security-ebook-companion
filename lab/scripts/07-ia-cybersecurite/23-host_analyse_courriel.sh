#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  Chapitre  : 23 — L'offensive à l'ère de l'IA
#  Exercice  : 1 (Débutant) — Analyser un courriel suspect (défensif)
#  Version   : fixture datasets/courriel-suspect.eml (grep)
#  Exécution : bash scripts/07-ia-cybersecurite/23-host_analyse_courriel.sh
#              (depuis lab/ ; aucun service requis)
#  Statut    : VALIDÉ (2026-08-12)
#
#  Adaptation Docker : l'exercice est une analyse d'en-têtes sur un
#  courriel fictif. La fixture .eml est fournie dans datasets/ ; le
#  script reproduit les commandes du manuel (grep des en-têtes) puis
#  vérifie la détection de l'écart Return-Path ≠ domaine affiché.
# ─────────────────────────────────────────────────────────────
set -euo pipefail
cd "$(dirname "$0")/../.."   # → lab/

EML=datasets/courriel-suspect.eml
echo "== Ch23 Ex1 — Analyser un courriel suspect (défensif) =="
fail=0

[ -f "$EML" ] || { echo "✗ fixture $EML absente"; exit 1; }

echo "--- 1. En-têtes ---"
grep -E "^(From|Return-Path|Reply-To|Received):" "$EML"

echo "--- 2. Analyse ---"
FROM_DOM=$(grep -m1 "^From:" "$EML" | sed -E 's/.*@([^ >]+).*/\1/')
RP_DOM=$(grep -m1 "^Return-Path:" "$EML" | sed -E 's/.*@([^ >]+).*/\1/')
echo "domaine affiché (From)   : $FROM_DOM"
echo "domaine réel (Return-Path) : $RP_DOM"
if [ "$FROM_DOM" != "$RP_DOM" ]; then
  echo "→ ÉCART détecté : le domaine affiché ne correspond pas à l'origine réelle (signal de phishing)."
else
  echo "→ domaines identiques."
fi

echo "--- 3. Vérification recommandée ---"
VERIF=$(cat <<'EOF'
- Contacter le prétendu expéditeur via un numéro/email officiel (autre canal).
- Ne jamais cliquer sur le lien ni répondre.
- Signaler au responsable / SOC (ch. 18) ; conserver le courriel comme preuve (ch. 19).
EOF
)
echo "$VERIF"

echo
echo "--- Vérifications ---"
grep -q "^From:" "$EML" && echo "✓ en-tête From présent" || { echo "✗ From absent"; fail=1; }
grep -q "^Return-Path:" "$EML" && echo "✓ en-tête Return-Path présent" || { echo "✗ Return-Path absent"; fail=1; }
grep -q "^Received:" "$EML" && echo "✓ chaîne Received présente (relais)" || { echo "✗ Received absent"; fail=1; }
echo "$FROM_DOM" | grep -q "alpha-services.example" && echo "✓ domaine affiché extrait" || { echo "✗ domaine affiché non extrait"; fail=1; }
[ "$FROM_DOM" != "$RP_DOM" ] && echo "✓ écart Return-Path ≠ From détecté (signal de phishing)" || { echo "✗ écart non détecté"; fail=1; }
echo "$VERIF" | grep -q "autre canal" && echo "✓ vérification par autre canal documentée" || { echo "✗ vérification absente"; fail=1; }

echo
if [ "$fail" -eq 0 ]; then
  echo "✅ Ch23 Ex1 : VALIDÉ"
else
  echo "❌ Ch23 Ex1 : ÉCHEC"
  exit 1
fi
