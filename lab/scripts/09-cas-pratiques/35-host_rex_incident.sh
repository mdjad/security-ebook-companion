#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  Chapitre  : 35 — Cas pratique : réponse à incident à l'ère de l'IA
#  Exercice  : 3 (Confirmé) — Rédiger le REX et la feuille de route
#  Version   : document (REX + actions datées)
#  Exécution : bash scripts/09-cas-pratiques/35-host_rex_incident.sh
#              (depuis lab/)
#  Statut    : VALIDÉ (2026-08-12)
#
#  Adaptation Docker : exercice document → validation par modèle de
#  structure (chronologie, causes racines, actions datées,
#  améliorations de détection). Reprend la correction du manuel.
# ─────────────────────────────────────────────────────────────
set -euo pipefail
cd "$(dirname "$0")/../.."   # → lab/

echo "== Ch35 Ex3 — REX et feuille de route =="
fail=0

DOC=/tmp/rex-incident.md
cat > "$DOC" <<'EOF'
# REX — incident ransomware (labo, fictif)

## Chronologie
| Heure | Événement |
|---|---|
| 09:00 | Courriel « augmenté » reçu |
| 09:20 | Exécution de la pièce jointe (compte utilisateur) |
| 09:45 | Alerte SOC : chiffrement massif |
| 10:00 | Isolation du serveur |

## Causes racines
1. Formation insuffisante au phishing génératif (ch. 23).
2. Absence de segmentation stricte (ch. 17).
3. Sauvegardes non testées récemment (ch. 13).

## Actions
| Action | Responsable | Échéance |
|---|---|---|
| Formation phishing augmenté | RH | 30 j |
| Segmentation des serveurs | Ops | 45 j |
| Test de restauration (3-2-1) | Ops | 15 j |
| Règle SOC : chiffrement massif | SOC | 15 j |

## Améliorations de détection
- Règle : extension de fichiers massifs / volume écrit.
- IoC du courriel partagés (threat intel, ch. 24).
- Exercices mensuels (ch. 35).
EOF

echo "--- Document généré ---"
cat "$DOC"

echo
echo "--- Vérifications ---"
grep -q "^## Chronologie" "$DOC" && echo "✓ chronologie" || { echo "✗ chronologie absente"; fail=1; }
grep -q "^## Causes racines" "$DOC" && echo "✓ causes racines" || { echo "✗ causes absentes"; fail=1; }
grep -q "^## Actions" "$DOC" && echo "✓ actions" || { echo "✗ actions absentes"; fail=1; }
grep -q "Responsable" "$DOC" && echo "✓ responsables assignés" || { echo "✗ responsables absents"; fail=1; }
grep -q "Échéance" "$DOC" && echo "✓ échéances datées" || { echo "✗ échéances absentes"; fail=1; }
grep -q "^## Améliorations de détection" "$DOC" && echo "✓ améliorations de détection" || { echo "✗ améliorations absentes"; fail=1; }

echo
if [ "$fail" -eq 0 ]; then
  echo "✅ Ch35 Ex3 : VALIDÉ"
else
  echo "❌ Ch35 Ex3 : ÉCHEC"
  exit 1
fi
