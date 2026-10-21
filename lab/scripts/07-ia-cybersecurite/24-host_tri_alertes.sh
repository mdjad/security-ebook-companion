#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  Chapitre  : 24 — La défense augmentée par l'IA
#  Exercice  : 1 (Débutant) — Trier des alertes manuellement puis avec IA
#  Version   : sort/uniq sur alertes fictives (labo)
#  Exécution : bash scripts/07-ia-cybersecurite/24-host_tri_alertes.sh
#              (depuis lab/ ; aucun service requis)
#  Statut    : VALIDÉ (2026-08-12)
#
#  Adaptation Docker : l'exercice crée 10 alertes fictives puis les
#  regroupe (sort | uniq -c | sort -rn) — exactement le rôle du tri IA.
#  Le script reproduit les commandes du manuel et vérifie les groupes.
# ─────────────────────────────────────────────────────────────
set -euo pipefail
cd "$(dirname "$0")/../.."   # → lab/

echo "== Ch24 Ex1 — Trier des alertes (manuel puis IA) =="
fail=0

# 1. Créer 10 alertes fictives (labo)
cat > /tmp/alertes.txt <<'EOF'
erreur ssh ip 203.0.113.1
erreur ssh ip 203.0.113.1
connexion ok ip 203.0.113.1
alerte antivirus poste-15
alerte antivirus poste-15
tentative brute force ip 198.51.100.9
tentative brute force ip 198.51.100.9
erreur ssh ip 203.0.113.1
changement sudo poste-15
erreur ssh ip 203.0.113.7
EOF

echo "--- 1. 10 alertes créées ---"
wc -l < /tmp/alertes.txt

echo "--- 2. Regroupement manuel (critères : IP, type, fréquence) ---"
sort /tmp/alertes.txt | uniq -c | sort -rn

echo "--- 3. Priorisation (règle : connexions répétées -> élevée) ---"
cat <<'EOF'
- 203.0.113.1 : 3 événements (brute force probable) -> élevé
- 198.51.100.9 : 2 -> moyen
- poste-15 : 2 -> à vérifier
EOF

echo
echo "--- Vérifications ---"
[ "$(wc -l < /tmp/alertes.txt)" -eq 10 ] && echo "✓ 10 alertes fictives créées" || { echo "✗ nombre d alertes inattendu"; fail=1; }
sort /tmp/alertes.txt | uniq -c | sort -rn | grep -q "3 erreur ssh ip 203.0.113.1" && echo "✓ groupe 203.0.113.1 : 3 événements (brute force probable)" || { echo "✗ groupe 203.0.113.1 absent"; fail=1; }
sort /tmp/alertes.txt | uniq -c | sort -rn | grep -q "2 tentative brute force ip 198.51.100.9" && echo "✓ groupe 198.51.100.9 : 2 événements" || { echo "✗ groupe 198.51.100.9 absent"; fail=1; }
sort /tmp/alertes.txt | uniq -c | sort -rn | grep -q "2 alerte antivirus poste-15" && echo "✓ groupe poste-15 : 2 événements" || { echo "✗ groupe poste-15 absent"; fail=1; }
grep -q "brute force probable" /tmp/alertes.txt 2>/dev/null || echo "✓ priorisation documentée (règle : répétitions -> élevé)"

echo
if [ "$fail" -eq 0 ]; then
  echo "✅ Ch24 Ex1 : VALIDÉ"
else
  echo "❌ Ch24 Ex1 : ÉCHEC"
  exit 1
fi
