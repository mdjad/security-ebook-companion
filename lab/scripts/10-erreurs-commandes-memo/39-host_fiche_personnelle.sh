#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  Chapitre  : 39 — Fiches mémo de révision
#  Exercice  : 1 (Débutant) — Créer une fiche personnelle
#  Version   : document (fiche « Mon poste de travail »)
#  Exécution : bash scripts/10-erreurs-commandes-memo/39-host_fiche_personnelle.sh
#              (depuis lab/)
#  Statut    : VALIDÉ (2026-08-12)
#
#  Adaptation Docker : exercice document → validation par modèle de
#  structure (schéma, essentiel 5 lignes, pièges 3). Reprend la
#  correction du manuel.
# ─────────────────────────────────────────────────────────────
set -euo pipefail
cd "$(dirname "$0")/../.."   # → lab/

echo "== Ch39 Ex1 — Fiche personnelle =="
fail=0

DOC=/tmp/fiche-poste-travail.md
cat > "$DOC" <<'EOF'
# MON POSTE DE TRAVAIL

## Schéma
+------------------------------------------+
| navigateur -> proxy -> services          |
|   ports : 443 (web), 22 (admin), ...     |
+------------------------------------------+

## L'essentiel
- système à jour + pare-feu actif
- compte non-root, MFA
- sauvegarde testée (3-2-1)
- journaux vers le SOC

## Pièges
- ports inutiles ouverts
- clés SSH sans passphrase
- sauvegarde jamais restaurée
EOF

echo "--- Fiche générée ---"
cat "$DOC"

echo
echo "--- Vérifications ---"
grep -q "^## Schéma" "$DOC" && echo "✓ schéma présent" || { echo "✗ schéma absent"; fail=1; }
grep -q "navigateur -> proxy" "$DOC" && echo "✓ schéma : flux navigateur" || { echo "✗ flux absent"; fail=1; }
grep -q "^## L'essentiel" "$DOC" && echo "✓ section essentiel" || { echo "✗ essentiel absent"; fail=1; }
grep -q "pare-feu actif" "$DOC" && echo "✓ essentiel : pare-feu" || { echo "✗ pare-feu absent"; fail=1; }
grep -q "^## Pièges" "$DOC" && echo "✓ section pièges" || { echo "✗ pièges absents"; fail=1; }
grep -q "clés SSH sans passphrase" "$DOC" && echo "✓ piège : clés sans passphrase" || { echo "✗ piège absent"; fail=1; }

echo
if [ "$fail" -eq 0 ]; then
  echo "✅ Ch39 Ex1 : VALIDÉ"
else
  echo "❌ Ch39 Ex1 : ÉCHEC"
  exit 1
fi
