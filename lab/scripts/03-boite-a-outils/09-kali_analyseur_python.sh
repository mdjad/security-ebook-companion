#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  Chapitre  : 09 — Scripting Bash et Python
#  Exercice  : 2 (Intermédiaire) — Analyseur Python de journaux
#  Version   : kali-rolling 2026.2 (python 3.12)
#  Exécution : bash scripts/03-boite-a-outils/09-kali_analyseur_python.sh
#              (depuis lab/ ; nécessite `make up-pentest`)
#  Statut    : VALIDÉ (2026-08-11)
#
#  Adaptation Docker : le script du manuel est exécuté tel quel sur
#  la fixture datasets/auth.log (connexions `Accepted` par heure et
#  par utilisateur). Le cas « fichier absent » est aussi testé.
# ─────────────────────────────────────────────────────────────
set -euo pipefail
cd "$(dirname "$0")/../.."   # → lab/

echo "== Ch09 Ex2 — Analyseur Python de connexions SSH acceptées =="
fail=0

# Script Python du manuel (reproduit à l'identique)
docker compose exec -T kali bash -c 'cat > /tmp/analyse_ssh.py <<'"'"'EOF'"'"'
#!/usr/bin/env python3
"""Analyse des connexions SSH acceptées."""
import re
import sys
from collections import Counter

chemin = sys.argv[1] if len(sys.argv) > 1 else "/var/log/auth.log"
pattern = re.compile(r"(\w{3}\s+\d+\s+\d+:\d+:\d+).*?Accepted.*?for (\w+)")

par_heure = Counter()
par_user = Counter()

try:
    with open(chemin, errors="ignore") as f:
        for ligne in f:
            m = pattern.search(ligne)
            if m:
                heure = m.group(1).split()[-1][:2]   # heure, 2 premiers chiffres
                par_heure[heure] += 1
                par_user[m.group(2)] += 1
except FileNotFoundError:
    print(f"Erreur : {chemin} introuvable.", file=sys.stderr)
    sys.exit(1)

print("Connexions par heure :")
for h, n in sorted(par_heure.items()):
    print(f"  {h}h : {n}")

print("Connexions par utilisateur :")
for u, n in par_user.most_common(10):
    print(f"  {u} : {n}")
EOF'

echo
echo "--- Exécution sur la fixture ---"
out=$(docker compose exec -T kali python3 /tmp/analyse_ssh.py /lab/datasets/auth.log)
echo "$out"
echo "$out" | grep -q "Connexions par heure" && echo "✓ agrégation par heure produite" || { echo "✗ section par heure absente"; fail=1; }
echo "$out" | grep -q "Connexions par utilisateur" && echo "✓ agrégation par utilisateur produite" || { echo "✗ section par utilisateur absente"; fail=1; }
echo "$out" | grep -qE "^\s+[0-9]+h : [0-9]+" && echo "✓ compteurs horaires non vides" || { echo "✗ compteurs horaires vides"; fail=1; }

echo
echo "--- Cas fichier absent (géré proprement) ---"
out=$(docker compose exec -T kali python3 /tmp/analyse_ssh.py /tmp/inexistant.log 2>&1 || true)
echo "$out"
echo "$out" | grep -q "introuvable" && echo "✓ erreur propre sur fichier absent" || { echo "✗ erreur non gérée"; fail=1; }

echo
if [ "$fail" -eq 0 ]; then
  echo "✅ Ch09 Ex2 : VALIDÉ"
else
  echo "❌ Ch09 Ex2 : ÉCHEC"
  exit 1
fi
