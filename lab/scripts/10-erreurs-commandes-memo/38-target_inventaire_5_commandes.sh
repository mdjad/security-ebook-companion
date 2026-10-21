#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  Chapitre  : 38 — 200 commandes de sécurité
#  Exercice  : 1 (Débutant) — Inventaire de sécurité
#  Version   : vuln-host (5 commandes en lecture seule)
#  Exécution : bash scripts/10-erreurs-commandes-memo/38-target_inventaire_5_commandes.sh
#              (depuis lab/ ; nécessite `make up`)
#  Statut    : VALIDÉ (2026-08-12)
#
#  Adaptation Docker : le manuel utilise hostnamectl + systemctl
#  (systemd, absent des conteneurs). Équivalents : /etc/os-release
#  (nom + OS), uname -r (noyau), hostname -I (IP), ss -tulpn
#  (ports), ls /etc/init.d (services). Même inventaire en 5
#  commandes, uniquement en lecture.
# ─────────────────────────────────────────────────────────────
set -euo pipefail
cd "$(dirname "$0")/../.."   # → lab/

echo "== Ch38 Ex1 — Inventaire de sécurité (5 commandes) =="
fail=0

OUT=$(docker compose exec -T vuln-host bash -c '
echo "--- 1. nom + OS ---"
grep -E "PRETTY_NAME" /etc/os-release
echo "--- 2. noyau ---"
uname -r
echo "--- 3. adresses IP ---"
hostname -I
echo "--- 4. ports en écoute ---"
ss -tulpn 2>/dev/null | grep LISTEN | awk "{print \$5}" | sort -u
echo "--- 5. services actifs ---"
ls /etc/init.d/ | grep -vE "^hwclock|^procps" | sort
')
echo "$OUT"

echo
echo "--- Vérifications ---"
echo "$OUT" | grep -q "Debian" && echo "✓ 1. nom + OS identifiés" || { echo "✗ OS absent"; fail=1; }
echo "$OUT" | grep -qE "^[0-9]+\.[0-9]+" && echo "✓ 2. noyau identifié (uname -r)" || { echo "✗ noyau absent"; fail=1; }
echo "$OUT" | grep -qE "^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+" && echo "✓ 3. adresse IP identifiée" || { echo "✗ IP absente"; fail=1; }
echo "$OUT" | grep -q ":22" && echo "✓ 4. port SSH (22) en écoute" || { echo "✗ port 22 absent"; fail=1; }
echo "$OUT" | grep -q ":80" && echo "✓ 4. port HTTP (80) en écoute" || { echo "✗ port 80 absent"; fail=1; }
echo "$OUT" | grep -q "nginx" && echo "✓ 5. service nginx actif" || { echo "✗ nginx absent"; fail=1; }

echo
if [ "$fail" -eq 0 ]; then
  echo "✅ Ch38 Ex1 : VALIDÉ"
else
  echo "❌ Ch38 Ex1 : ÉCHEC"
  exit 1
fi
