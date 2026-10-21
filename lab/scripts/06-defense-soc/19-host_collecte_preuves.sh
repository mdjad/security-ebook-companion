#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  Chapitre  : 19 — Gestion des incidents et forensique
#  Exercice  : 1 (Débutant) — Collecter des preuves (chaîne de garde)
#  Version   : vuln-host (debian:bookworm), fixture datasets/auth.log
#  Exécution : bash scripts/06-defense-soc/19-host_collecte_preuves.sh
#              (depuis lab/ ; nécessite `make up-pentest`)
#  Statut    : VALIDÉ (2026-08-12)
#
#  Adaptation Docker : le manuel copie journalctl -u sshd (systemd
#  absent des conteneurs) → on copie la fixture auth.log (même
#  scénario : connexions suspectes dans sshd). Le reste est fidèle :
#  dossier horodaté, copie, ss -tunap, date -u, sha256sum, puis
#  vérification d'intégrité (sha256sum -c).
# ─────────────────────────────────────────────────────────────
set -euo pipefail
cd "$(dirname "$0")/../.."   # → lab/

echo "== Ch19 Ex1 — Collecte de preuves (chaîne de garde) =="
fail=0

out=$(docker compose exec -T vuln-host bash -c '
set -e
# 1. Dossier horodaté
DEST=/tmp/preuves/$(date +%F)
mkdir -p "$DEST"

# 2. Journaux (copie, pas lecture directe de la source)
cp /lab/datasets/auth.log "$DEST/sshd.log"

# 3. Connexions actives
ss -tunap > "$DEST/connexions.txt"

# 4. Horodatage et hashes
# NB : on hache explicitement les pièces (jamais hashes.txt lui-même,
# sinon la vérification échoue au 2e passage — fichier auto-référent).
date -u > "$DEST/horodatage.txt"
sha256sum "$DEST/sshd.log" "$DEST/connexions.txt" "$DEST/horodatage.txt" > "$DEST/hashes.txt"

echo "--- contenu du dossier de preuves ---"
ls -la "$DEST"
echo "--- hashes ---"
cat "$DEST/hashes.txt"

# 5. Vérifier l intégrité de la collecte
echo "--- vérification d intégrité ---"
sha256sum -c "$DEST/hashes.txt"
')
echo "$out"

echo
echo "--- Vérifications ---"
echo "$out" | grep -q "sshd.log" && echo "✓ journal sshd copié (fixture auth.log)" || { echo "✗ sshd.log absent"; fail=1; }
echo "$out" | grep -q "connexions.txt" && echo "✓ connexions actives capturées (ss -tunap)" || { echo "✗ connexions.txt absent"; fail=1; }
echo "$out" | grep -q "horodatage.txt" && echo "✓ horodatage UTC présent" || { echo "✗ horodatage absent"; fail=1; }
echo "$out" | grep -q "OK" && echo "✓ sha256sum -c : intégrité vérifiée (OK)" || { echo "✗ vérification d intégrité en échec"; fail=1; }

echo
if [ "$fail" -eq 0 ]; then
  echo "✅ Ch19 Ex1 : VALIDÉ"
else
  echo "❌ Ch19 Ex1 : ÉCHEC"
  exit 1
fi
