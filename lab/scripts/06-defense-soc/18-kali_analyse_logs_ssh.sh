#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  Chapitre  : 18 — Surveillance, détection et réponse
#  Exercice  : 1 (Débutant) — Analyser des journaux SSH
#  Version   : kali (grep/awk), fixture datasets/auth.log
#  Exécution : bash scripts/06-defense-soc/18-kali_analyse_logs_ssh.sh
#              (depuis lab/ ; nécessite `make up-pentest`)
#  Statut    : VALIDÉ (2026-08-12)
#
#  Adaptation Docker : le manuel lit journalctl -u sshd (systemd,
#  absent des conteneurs). On analyse la fixture datasets/auth.log
#  (même format Debian, mêmes pipelines grep/awk/sort/uniq).
#  La règle de détection (5 échecs / 60 s → alerte) est formulée
#  et reliée à MITRE ATT&CK T1110 (Brute Force).
# ─────────────────────────────────────────────────────────────
set -euo pipefail
cd "$(dirname "$0")/../.."   # → lab/

echo "== Ch18 Ex1 — Analyser des journaux SSH =="
fail=0

out=$(docker compose exec -T kali bash -c '
set -e
LOG=/lab/datasets/auth.log
echo "--- 1. Échecs d authentification (24 h) ---"
echo "échecs : $(grep -c "Failed password" "$LOG")"

echo "--- 2. IP sources les plus actives ---"
grep "Failed password" "$LOG" | awk "{print \$(NF-3)}" | sort | uniq -c | sort -rn

echo "--- 3. Règle de détection (pseudo) ---"
echo "5 échecs depuis une même IP en 60 s -> alerte (MITRE ATT&CK T1110 Brute Force)"
')
echo "$out"

echo
echo "--- Vérifications ---"
echo "$out" | grep -q "échecs : 29" && echo "✓ 29 échecs comptés (fixture)" || { echo "✗ comptage inattendu"; fail=1; }
echo "$out" | grep -q "13 203.0.113.10" && echo "✓ IP la plus active : 203.0.113.10 (13 échecs)" || { echo "✗ top IP absent"; fail=1; }
echo "$out" | grep -q "11 198.51.100.7" && echo "✓ 2e IP : 198.51.100.7 (11 échecs)" || { echo "✗ 2e IP absente"; fail=1; }
echo "$out" | grep -q "T1110" && echo "✓ règle reliée à MITRE ATT&CK T1110" || { echo "✗ règle T1110 absente"; fail=1; }

echo
if [ "$fail" -eq 0 ]; then
  echo "✅ Ch18 Ex1 : VALIDÉ"
else
  echo "❌ Ch18 Ex1 : ÉCHEC"
  exit 1
fi
