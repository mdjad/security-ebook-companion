#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  Chapitre  : 18 — Surveillance, détection et réponse
#  Exercice  : 2 (Intermédiaire) — Concevoir une règle de corrélation
#  Version   : validation par modèle de document (MITRE ATT&CK)
#  Exécution : bash scripts/06-defense-soc/18-host_regle_correlation.sh
#              (depuis lab/ ; aucun service requis)
#  Statut    : VALIDÉ (2026-08-12)
#
#  Adaptation Docker : l'exercice est un document. Le script génère
#  la règle SIEM (mouvement latéral dev → base) et vérifie la
#  structure : événements corrélés, condition, niveau, action.
# ─────────────────────────────────────────────────────────────
set -euo pipefail
cd "$(dirname "$0")/../.."   # → lab/

echo "== Ch18 Ex2 — Règle de corrélation (document) =="
fail=0

cat > /tmp/regle-correlation.md <<'EOF'
# Règle : mouvement latéral probable (dev -> base)

## Événements corrélés
1. Échecs SSH répétés depuis une IP externe (T1110)
2. Connexion réussie depuis cette IP (T1078)
3. Exécution d'un binaire non répertorié (T1059)
4. Connexions sortantes vers le segment bases (T1021)

## Condition
  1 + 2 + 3 + 4 dans une fenêtre de 30 minutes

## Niveau
Élevé — signaler au SOC

## Action
- Isoler le serveur (EDR/IPS)
- Prévenir l'équipe (playbook ch. 19)
- Conserver les journaux (preuves, chaîne de garde)
EOF

echo "--- Document généré ---"
cat /tmp/regle-correlation.md

echo
echo "--- Vérifications de structure ---"
for section in "Événements corrélés" "Condition" "Niveau" "Action"; do
  grep -q "^## $section" /tmp/regle-correlation.md && echo "✓ section « $section » présente" || { echo "✗ section « $section » absente"; fail=1; }
done
for t in T1110 T1078 T1059 T1021; do
  grep -q "$t" /tmp/regle-correlation.md && echo "✓ technique MITRE $t présente" || { echo "✗ $t absente"; fail=1; }
done
grep -q "30 minutes" /tmp/regle-correlation.md && echo "✓ fenêtre de corrélation (30 min) présente" || { echo "✗ fenêtre absente"; fail=1; }
grep -q "chaîne de garde" /tmp/regle-correlation.md && echo "✓ action « chaîne de garde » présente" || { echo "✗ action absente"; fail=1; }

echo
if [ "$fail" -eq 0 ]; then
  echo "✅ Ch18 Ex2 : VALIDÉ"
else
  echo "❌ Ch18 Ex2 : ÉCHEC"
  exit 1
fi
