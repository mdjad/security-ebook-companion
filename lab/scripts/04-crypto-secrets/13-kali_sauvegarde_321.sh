#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  Chapitre  : 13 — Secrets, données et sauvegardes
#  Exercice  : 2 (Intermédiaire) — Plan de sauvegarde 3-2-1 avec test de restauration
#  Version   : kali-rolling 2026.2 (tar, openssl 3.x)
#  Exécution : bash scripts/04-crypto-secrets/13-kali_sauvegarde_321.sh
#              (depuis lab/ ; nécessite `make up-pentest`)
#  Statut    : VALIDÉ (2026-08-11)
#
#  Adaptation Docker : les « supports » (NAS, USB) sont des dossiers
#  locaux du conteneur ; le principe 3-2-1 et le test de restauration
#  sont identiques au manuel.
#
#  ⚠️ CORRECTION MANUEL : `openssl enc -aes-256-gcm` ne fonctionne
#  PAS (AEAD non supporté par `enc`) → `-aes-256-cbc` ici.
# ─────────────────────────────────────────────────────────────
set -euo pipefail
cd "$(dirname "$0")/../.."   # → lab/

echo "== Ch13 Ex2 — Sauvegarde 3-2-1 avec test de restauration =="
fail=0

out=$(docker compose exec -T kali bash -c '
set -e
# Données à protéger
mkdir -p /srv/donnees /mnt/nas /mnt/usb-externe /tmp/restauration-test
echo "rapport-2026.txt" > /srv/donnees/rapport-2026.txt
echo "base-export.csv" > /srv/donnees/base-export.csv

# 1. Sauvegarde chiffrée quotidienne
tar czf - /srv/donnees \
  | openssl enc -aes-256-cbc -pbkdf2 -pass pass:test \
    -out /mnt/nas/sauvegarde-2026-08-11.enc

# 2. Copie sur second support (NAS local) + hors-site hors-ligne
cp /mnt/nas/sauvegarde-2026-08-11.enc /mnt/usb-externe/

# 3. Test de restauration
openssl enc -d -aes-256-cbc -pbkdf2 -pass pass:test \
  -in /mnt/nas/sauvegarde-2026-08-11.enc \
  | tar xzf - -C /tmp/restauration-test/
diff -r /srv/donnees /tmp/restauration-test/srv/donnees && echo "RESTAURATION OK"
')
echo "$out"

echo
echo "--- Vérifications ---"
echo "$out" | grep -q "RESTAURATION OK" && echo "✓ restauration testée et identique (diff vide)" || { echo "✗ restauration en échec"; fail=1; }
n=$(docker compose exec -T kali bash -c "ls /mnt/nas/*.enc /mnt/usb-externe/*.enc 2>/dev/null | wc -l")
echo "copies chiffrées : $n (3-2-1 : 2 supports + 1 hors-ligne)"
[ "$n" -ge 2 ] && echo "✓ copies sur 2 supports" || { echo "✗ copies insuffisantes"; fail=1; }

echo
if [ "$fail" -eq 0 ]; then
  echo "✅ Ch13 Ex2 : VALIDÉ"
else
  echo "❌ Ch13 Ex2 : ÉCHEC"
  exit 1
fi
