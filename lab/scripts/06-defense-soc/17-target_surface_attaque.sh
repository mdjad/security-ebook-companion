#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  Chapitre  : 17 — Durcissement des systèmes
#  Exercice  : 1 (Débutant) — Réduire la surface d'attaque
#  Version   : debian:bookworm (vuln-host), ss (iproute2)
#  Exécution : bash scripts/06-defense-soc/17-target_surface_attaque.sh
#              (depuis lab/ ; nécessite `make up-pentest`)
#  Statut    : VALIDÉ (2026-08-12)
#
#  Adaptation Docker : le manuel désactive rpcbind/cups/avahi-daemon
#  via systemctl (absent des conteneurs). Ici, le service superflu
#  est vsftpd (FTP non chiffré, inutile sur la cible) : on l'arrête,
#  on vérifie la fermeture du port 21, puis on le redémarre pour ne
#  pas casser les exercices de pentest (Ch15/16 scannent le port 21).
#  La leçon est identique : inventaire avant/après + désactivation.
# ─────────────────────────────────────────────────────────────
set -euo pipefail
cd "$(dirname "$0")/../.."   # → lab/

echo "== Ch17 Ex1 — Réduire la surface d'attaque =="
fail=0

out=$(docker compose exec -T vuln-host bash -c '
set -e
echo "--- 1. Avant : inventaire des ports en écoute ---"
ss -tulpn | grep LISTEN

echo "--- 2. Service superflu identifié : vsftpd (FTP non chiffré) ---"
pgrep -a vsftpd || true

echo "--- 3. Désactivation ---"
pkill vsftpd || true
sleep 1

echo "--- 4. Après : inventaire ---"
ss -tulpn | grep LISTEN

echo "--- 5. Journalisation ---"
echo "$(date -u) : vsftpd désactivé (surface réduite)" >> /var/log/durcissement.log
tail -1 /var/log/durcissement.log

echo "--- 6. Restauration (pour les exercices de pentest) ---"
/usr/sbin/vsftpd /etc/vsftpd.conf >/var/log/vsftpd.log 2>&1 &
sleep 1
ss -tln | grep -q ":21 " && echo "port 21 de nouveau ouvert"
')
echo "$out"

echo
echo "--- Vérifications ---"
echo "$out" | grep -q ":21 " && echo "✓ avant : port 21 (FTP) en écoute" || { echo "✗ port 21 absent avant"; fail=1; }
echo "$out" | grep -q "vsftpd désactivé" && echo "✓ désactivation journalisée (durcissement.log)" || { echo "✗ journal absent"; fail=1; }
echo "$out" | grep -q "port 21 de nouveau ouvert" && echo "✓ restauration : port 21 réouvert (pentest intacts)" || { echo "✗ restauration échouée"; fail=1; }

echo
if [ "$fail" -eq 0 ]; then
  echo "✅ Ch17 Ex1 : VALIDÉ"
else
  echo "❌ Ch17 Ex1 : ÉCHEC"
  exit 1
fi
