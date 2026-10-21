#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  Chapitre  : 06 — Linux et les commandes essentielles de sécurité
#  Exercice  : 1 (Débutant) — Inventaire de sécurité d'une machine locale
#  Version   : vuln-host (debian:bookworm) — conteneur du lab
#  Exécution : bash scripts/02-socle-technique/06-target_inventaire_securite.sh
#              (depuis lab/ ; nécessite `make up`)
#  Statut    : VALIDÉ (2026-08-11)
#
#  Adaptations Docker (voir VALIDATION.md) :
#    • `systemctl list-units` (systemd) n'existe pas dans un conteneur
#      → remplacé par `ps -ef` (processus actifs).
#    • `journalctl` (journald) n'existe pas → fixture synthétique
#      datasets/auth.log montée dans la cible.
# ─────────────────────────────────────────────────────────────
set -euo pipefail
cd "$(dirname "$0")/../.."   # → lab/

echo "== Ch06 Ex1 — Inventaire de sécurité (cible : vuln-host) =="
fail=0

echo
echo "--- 1. Comptes avec un shell interactif ---"
out=$(docker compose exec -T vuln-host bash -c "getent passwd | grep -E '/(bash|sh|zsh)$'")
echo "$out"
echo "$out" | grep -q "admin"      || { echo "✗ admin absent"; fail=1; }
echo "$out" | grep -q "svc_backup"  || { echo "✗ svc_backup absent"; fail=1; }
echo "✓ comptes avec shell détectés"

echo
echo "--- 2. Processus actifs (adaptation : ps -ef au lieu de systemctl) ---"
out=$(docker compose exec -T vuln-host bash -c "ps -ef | grep -E 'sshd|vsftpd|nginx|mariadbd' | grep -v grep")
echo "$out"
echo "$out" | grep -q "sshd"     || { echo "✗ sshd absent"; fail=1; }
echo "$out" | grep -q "vsftpd"   || { echo "✗ vsftpd absent"; fail=1; }
echo "$out" | grep -q "nginx"    || { echo "✗ nginx absent"; fail=1; }
echo "$out" | grep -q "mariadbd" || { echo "✗ mariadbd absent"; fail=1; }
echo "✓ services actifs détectés"

echo
echo "--- 3. Ports en écoute et processus ---"
out=$(docker compose exec -T vuln-host bash -c "ss -tulpn")
echo "$out" | grep -E ":(22|21|80|3306) " | head -8
for p in 22 21 80 3306; do
  echo "$out" | grep -qE ":$p " || { echo "✗ port $p non écouté"; fail=1; }
done
echo "✓ ports 22/21/80/3306 en écoute"

echo
echo "--- 4. Échecs d'authentification (adaptation : fixture auth.log) ---"
n=$(grep -ci "failed password" datasets/auth.log || true)
echo "échecs d'authentification : $n"
[ "$n" -gt 0 ] || { echo "✗ aucun échec dans la fixture"; fail=1; }
echo "✓ échecs d'authentification détectés"

echo
echo "--- 5. Binaires SUID ---"
# NB : `find /` retourne 1 dans un conteneur (erreurs de traversée
# sur /proc, etc.) même avec 2>/dev/null → || true pour la validation.
out=$(docker compose exec -T vuln-host bash -c "find / -perm -4000 -type f 2>/dev/null" || true)
echo "$out"
echo "$out" | grep -q "backup-helper" || { echo "✗ SUID anormal backup-helper absent"; fail=1; }
echo "✓ SUID anormal détecté (backup-helper)"

echo
if [ "$fail" -eq 0 ]; then
  echo "✅ Ch06 Ex1 : VALIDÉ"
else
  echo "❌ Ch06 Ex1 : ÉCHEC"
  exit 1
fi
