#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  Chapitre  : 32 — Cas pratique : test d'intrusion web
#  Exercice  : 1 (Débutant) — Préparer les règles d'engagement
#  Version   : document (cadre de test)
#  Exécution : bash scripts/09-cas-pratiques/32-host_regles_engagement.sh
#              (depuis lab/)
#  Statut    : VALIDÉ (2026-08-12)
#
#  Adaptation Docker : le manuel cible http://web-vuln.lab (IP
#  VirtualBox 10.77.0.20). Dans le lab, l'application est
#  vuln-api (Ch27-28), joignable par nom de conteneur depuis
#  kali, et via edge sur 127.0.0.1:18083 depuis l'hôte. Le
#  document reprend la structure du manuel (cible, portée,
#  fenêtre, contraintes, contacts).
# ─────────────────────────────────────────────────────────────
set -euo pipefail
cd "$(dirname "$0")/../.."   # → lab/

echo "== Ch32 Ex1 — Règles d'engagement (test web) =="
fail=0

DOC=/tmp/regles-engagement.md
cat > "$DOC" <<'EOF'
# Règles d'engagement — test web (labo)

## Cible
- Application : vuln-api (Ch27-28) — http://vuln-api:5000 (réseau interne)
- Accès hôte : http://127.0.0.1:18083 (via edge)
- Environnement : laboratoire personnel, réseau isolé (seclab-internal).

## Portée
- Endpoints de l'API : /api/* (Ch27) et /v1/* (Ch28).
- Hors portée : autres machines, réseau de l'hôte, Internet.

## Fenêtre
- Dates/heures : [ex. 2026-08-17 → 2026-08-21], 9h-17h.

## Contraintes
- Aucune dégradation ni destruction.
- Aucune donnée réelle ; comptes de test uniquement (A / B).
- Arrêt si comportement inattendu ; contact du propriétaire.

## Contacts
- Propriétaire du labo ; documentation des incidents (ch. 19).
EOF

echo "--- Document généré ---"
cat "$DOC"

echo
echo "--- Vérifications ---"
grep -q "^## Cible" "$DOC" && echo "✓ section Cible" || { echo "✗ Cible absente"; fail=1; }
grep -q "^## Portée" "$DOC" && echo "✓ section Portée" || { echo "✗ Portée absente"; fail=1; }
grep -q "^## Fenêtre" "$DOC" && echo "✓ section Fenêtre" || { echo "✗ Fenêtre absente"; fail=1; }
grep -q "^## Contraintes" "$DOC" && echo "✓ section Contraintes" || { echo "✗ Contraintes absentes"; fail=1; }
grep -q "^## Contacts" "$DOC" && echo "✓ section Contacts" || { echo "✗ Contacts absents"; fail=1; }
grep -q "Hors portée" "$DOC" && echo "✓ hors portée défini" || { echo "✗ hors portée absent"; fail=1; }
grep -q "comptes de test" "$DOC" && echo "✓ comptes de test uniquement" || { echo "✗ contrainte comptes absente"; fail=1; }

echo
if [ "$fail" -eq 0 ]; then
  echo "✅ Ch32 Ex1 : VALIDÉ"
else
  echo "❌ Ch32 Ex1 : ÉCHEC"
  exit 1
fi
