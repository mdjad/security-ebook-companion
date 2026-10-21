#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  Chapitre  : 09 — Scripting Bash et Python
#  Exercice  : 1 (Débutant) — Script Bash d'analyse d'échecs SSH
#  Version   : kali-rolling 2026.2 (bash 5.2)
#  Exécution : bash scripts/03-boite-a-outils/09-kali_script_bash_ssh.sh
#              (depuis lab/ ; nécessite `make up-pentest`)
#  Statut    : VALIDÉ (2026-08-11)
#
#  Adaptation Docker : le manuel lit `journalctl -u sshd` (systemd,
#  absent d'un conteneur) → le script est exécuté sur la fixture
#  synthétique datasets/auth.log (même format Debian/Ubuntu).
# ─────────────────────────────────────────────────────────────
set -euo pipefail
cd "$(dirname "$0")/../.."   # → lab/

echo "== Ch09 Ex1 — Script Bash : top 10 des sources de force brute =="
fail=0

# Le script du manuel, adapté à la fixture (même pipeline grep/awk/sort/uniq)
docker compose exec -T kali bash -c 'cat > /tmp/analyse_ssh.sh <<'"'"'EOF'"'"'
#!/bin/bash
set -euo pipefail
LOG="/lab/datasets/auth.log"

echo "Top 10 des sources d'\''échecs SSH :"
grep "Failed password" "$LOG" \
  | awk '"'"'{print $(NF-3)}'"'"' \
  | sort | uniq -c | sort -rn | head -10
EOF
chmod +x /tmp/analyse_ssh.sh
bash /tmp/analyse_ssh.sh'

echo
echo "--- Vérification : le script s'exécute et produit un classement ---"
out=$(docker compose exec -T kali bash /tmp/analyse_ssh.sh)
echo "$out"
echo "$out" | grep -qE "^[[:space:]]*[0-9]+[[:space:]]+203\.0\.113\.10" && echo "✓ IP 203.0.113.10 classée (source la plus active)" || { echo "✗ IP attendue absente"; fail=1; }
echo "$out" | grep -qE "^[[:space:]]*[0-9]+[[:space:]]+198\.51\.100\.7" && echo "✓ IP 198.51.100.7 classée" || { echo "✗ IP secondaire absente"; fail=1; }

echo
if [ "$fail" -eq 0 ]; then
  echo "✅ Ch09 Ex1 : VALIDÉ"
else
  echo "❌ Ch09 Ex1 : ÉCHEC"
  exit 1
fi
