#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  Chapitre  : 37 — 100 erreurs de cybersécurité
#  Exercice  : 1 (Débutant) — Réviser 10 erreurs de son domaine
#  Version   : document (checklist section B + 3 actions)
#  Exécution : bash scripts/10-erreurs-commandes-memo/37-host_reviser_erreurs.sh
#              (depuis lab/)
#  Statut    : VALIDÉ (2026-08-12)
#
#  Adaptation Docker : exercice document → validation par modèle de
#  structure (checklist cochée, 3 actions reliées aux chapitres).
#  Reprend la correction du manuel (ch. 6, 17).
# ─────────────────────────────────────────────────────────────
set -euo pipefail
cd "$(dirname "$0")/../.."   # → lab/

echo "== Ch37 Ex1 — Réviser 10 erreurs (section B) =="
fail=0

DOC=/tmp/revision-erreurs.md
cat > "$DOC" <<'EOF'
# Section B : Systèmes et accès (extrait)

- [x] 12. Root activé en SSH -> clés + PermitRootLogin no (ch. 17)
- [x] 14. Aucun pare-feu -> ufw deny incoming (ch. 17)
- [ ] 17. Droits trop larges -> moindre privilège (ch. 6)

# Actions (3)
1. 12 : configurer SSH (clés, root no) -> vérifié par sshd -T
2. 14 : activer ufw -> vérifié par ufw status
3. 17 : revue des comptes -> vérifié par id / groups
EOF

echo "--- Document généré ---"
cat "$DOC"

echo
echo "--- Vérifications ---"
grep -q "12. Root activé en SSH" "$DOC" && echo "✓ erreur 12 cochée" || { echo "✗ erreur 12 absente"; fail=1; }
grep -q "14. Aucun pare-feu" "$DOC" && echo "✓ erreur 14 cochée" || { echo "✗ erreur 14 absente"; fail=1; }
grep -q "17. Droits trop larges" "$DOC" && echo "✓ erreur 17 (non cochée)" || { echo "✗ erreur 17 absente"; fail=1; }
grep -q "^# Actions (3)" "$DOC" && echo "✓ 3 actions proposées" || { echo "✗ actions absentes"; fail=1; }
grep -q "ch. 17" "$DOC" && echo "✓ corrections reliées aux chapitres" || { echo "✗ références absentes"; fail=1; }
grep -q "sshd -T" "$DOC" && echo "✓ vérification par commande" || { echo "✗ vérification absente"; fail=1; }

echo
if [ "$fail" -eq 0 ]; then
  echo "✅ Ch37 Ex1 : VALIDÉ"
else
  echo "❌ Ch37 Ex1 : ÉCHEC"
  exit 1
fi
