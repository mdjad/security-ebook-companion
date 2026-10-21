#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  Chapitre  : 29 — Sécurité cloud et conteneurs
#  Exercice  : 1 (Débutant) — Cartographier une responsabilité partagée
#  Version   : validation par modèle de document (PaaS vs IaaS)
#  Exécution : bash scripts/08-web-cloud-devsecops/29-host_responsabilite_partagee.sh
#              (depuis lab/ ; aucun service requis)
#  Statut    : VALIDÉ (2026-08-12)
#
#  Adaptation Docker : l'exercice est un document. Le script génère
#  la cartographie (PaaS + IaaS) et vérifie la structure complète
#  (sections, tableaux, colonnes Fournisseur/Client).
# ─────────────────────────────────────────────────────────────
set -euo pipefail
cd "$(dirname "$0")/../.."   # → lab/

echo "== Ch29 Ex1 — Responsabilité partagée (document) =="
fail=0

cat > /tmp/responsabilite-partagee.md <<'EOF'
# Responsabilité partagée (fictif)

## Base de données gérée (PaaS)
| Domaine | Fournisseur | Client |
|---|---|---|
| Matériel / mise à jour du moteur | ✓ | — |
| Comptes et accès | — | ✓ (IAM, MFA) |
| Données | stockage | ✓ (accès, chiffrement, ch. 12) |
| Sauvegardes | ✓ (outil) | ✓ (test des restaurations, ch. 13) |

## Machine virtuelle (IaaS)
| Domaine | Fournisseur | Client |
|---|---|---|
| Hyperviseur / centre de données | ✓ | — |
| OS et applications | — | ✓ (durcissement ch. 17) |
| Pare-feu de la VM | — | ✓ (ufw, règles) |
| Journalisation | — | ✓ (auditd, ch. 18) |
EOF

echo "--- structure générée ---"
cat /tmp/responsabilite-partagee.md

echo
echo "--- Vérifications ---"
grep -q "^# Responsabilité partagée" /tmp/responsabilite-partagee.md && echo "✓ titre présent" || { echo "✗ titre absent"; fail=1; }
grep -q "^## Base de données gérée (PaaS)" /tmp/responsabilite-partagee.md && echo "✓ section PaaS présente" || { echo "✗ section PaaS absente"; fail=1; }
grep -q "^## Machine virtuelle (IaaS)" /tmp/responsabilite-partagee.md && echo "✓ section IaaS présente" || { echo "✗ section IaaS absente"; fail=1; }
grep -q "| Domaine | Fournisseur | Client |" /tmp/responsabilite-partagee.md && echo "✓ colonnes Fournisseur/Client présentes" || { echo "✗ colonnes absentes"; fail=1; }
grep -q "durcissement ch. 17" /tmp/responsabilite-partagee.md && echo "✓ renvoi ch. 17 (durcissement)" || { echo "✗ renvoi ch. 17 absent"; fail=1; }
grep -q "auditd, ch. 18" /tmp/responsabilite-partagee.md && echo "✓ renvoi ch. 18 (journalisation)" || { echo "✗ renvoi ch. 18 absent"; fail=1; }

echo
if [ "$fail" -eq 0 ]; then
  echo "✅ Ch29 Ex1 : VALIDÉ"
else
  echo "❌ Ch29 Ex1 : ÉCHEC"
  exit 1
fi
