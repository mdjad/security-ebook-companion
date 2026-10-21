#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  Chapitre  : 19 — Gestion des incidents et forensique
#  Exercice  : 2 (Intermédiaire) — Rédiger un plan de réponse et un REX
#  Version   : validation par modèle de document
#  Exécution : bash scripts/06-defense-soc/19-host_plan_reponse_rex.sh
#              (depuis lab/ ; aucun service requis)
#  Statut    : VALIDÉ (2026-08-12)
#
#  Adaptation Docker : l'exercice est un document. Le script génère
#  le playbook (détection → contenance → analyse → éradication →
#  récupération) puis le REX (causes racines + actions datées) et
#  vérifie la structure complète.
# ─────────────────────────────────────────────────────────────
set -euo pipefail
cd "$(dirname "$0")/../.."   # → lab/

echo "== Ch19 Ex2 — Plan de réponse + REX (document) =="
fail=0

cat > /tmp/plan-reponse-rex.md <<'EOF'
# Playbook : compte compromis par phishing

## Détection
- Alerte SIEM (connexion anormale, ch. 18) ; plainte utilisateur.

## Contenance (heure 1)
- Bloquer le compte (IAM), révoquer les sessions.
- Conserver les journaux (chaîne de garde).

## Analyse
- Identifier la cause (phishing), la portée (accès, données), les IoC.

## Éradication
- Rotation des secrets (ch. 13), MFA, patchs, sensibilisation.

## Récupération
- Restaurer les accès légitimes, surveiller renforcé.

# REX
## Causes racines
1. Sensibilisation insuffisante au phishing ciblé.
2. Absence de MFA sur le compte.
3. Détection trop tardive des connexions anormales.

## Actions
| Action | Responsable | Échéance |
|---|---|---|
| Déployer la MFA | Équipe IAM | 30 j |
| Formation phishing | RH | 45 j |
| Règle SIEM connexions anormales | SOC | 15 j |
EOF

echo "--- Document généré ---"
cat /tmp/plan-reponse-rex.md

echo
echo "--- Vérifications de structure ---"
for phase in "Détection" "Contenance" "Analyse" "Éradication" "Récupération"; do
  grep -q "^## $phase" /tmp/plan-reponse-rex.md && echo "✓ phase « $phase » présente" || { echo "✗ phase « $phase » absente"; fail=1; }
done
grep -q "^# REX" /tmp/plan-reponse-rex.md && echo "✓ section REX présente" || { echo "✗ REX absent"; fail=1; }
grep -q "^## Causes racines" /tmp/plan-reponse-rex.md && echo "✓ causes racines présentes" || { echo "✗ causes racines absentes"; fail=1; }
grep -q "| Action | Responsable | Échéance |" /tmp/plan-reponse-rex.md && echo "✓ tableau d actions (responsable + échéance) présent" || { echo "✗ tableau d actions absent"; fail=1; }
grep -q "MFA" /tmp/plan-reponse-rex.md && echo "✓ action MFA (ch. 13) présente" || { echo "✗ action MFA absente"; fail=1; }
grep -q "chaîne de garde" /tmp/plan-reponse-rex.md && echo "✓ chaîne de garde mentionnée" || { echo "✗ chaîne de garde absente"; fail=1; }

echo
if [ "$fail" -eq 0 ]; then
  echo "✅ Ch19 Ex2 : VALIDÉ"
else
  echo "❌ Ch19 Ex2 : ÉCHEC"
  exit 1
fi
