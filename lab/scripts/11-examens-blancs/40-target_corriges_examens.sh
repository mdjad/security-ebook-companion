#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  Chapitre  : 40 — Examen blanc n°1 (ch. 1-22)
#  Vérifie   : les commandes des corrigés (Ex2 inventaire, Ex4 intégrité)
#  Version   : vuln-host (cible du lab)
#  Exécution : bash scripts/11-examens-blancs/40-target_corriges_examens.sh
#              (depuis lab/ ; nécessite `make up`)
#  Statut    : VALIDÉ (2026-08-12)
#
#  Corrigé Ex2 : `hostname -I` ; `ss -tulpn` ; `systemctl list-units
#  --type=service --state=running`. Adaptation lab : pas de systemd en
#  conteneur → `ps -ef` + `ls /etc/init.d/` (même inventaire, cf. Ch38).
#  Corrigé Ex4 : `sha256sum config.txt > somme.sha256` puis `-c` (OK).
# ─────────────────────────────────────────────────────────────
set -euo pipefail
cd "$(dirname "$0")/../.."   # → lab/

echo "== Ch40 — Corrigés des exercices (Ex2 + Ex4) =="
fail=0

echo "--- Ex2 : inventaire réseau (3 commandes) ---"
echo "==> hostname -I (adresses IP)"
IPS=$(docker compose exec -T vuln-host hostname -I | tr -d ' ')
echo "IP : $IPS"
echo "==> ss -tulpn (ports en écoute)"
docker compose exec -T vuln-host ss -tulpn | awk 'NR==1 || /LISTEN/' | head -8
echo "==> services actifs (systemctl → adaptation lab : ps + init.d)"
docker compose exec -T vuln-host bash -c 'ps -ef | grep -v grep | grep -E "nginx|sshd|vsftpd|mariadb|mysqld" | awk "{print \$8, \$9}" | sort -u'
docker compose exec -T vuln-host bash -c 'ls /etc/init.d/ 2>/dev/null | head -8'

echo "--- Ex4 : intégrité (sha256sum produire + vérifier) ---"
docker compose exec -T vuln-host bash -c '
  cd /tmp
  echo "server { listen 80; }" > config.txt
  sha256sum config.txt > somme.sha256
  echo "somme : $(cat somme.sha256)"
  VERIF=$(sha256sum -c somme.sha256)
  echo "vérification : $VERIF"
  echo "$VERIF" | grep -q ": OK"
'

echo
echo "--- Vérifications ---"
echo "$IPS" | grep -qE "^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+" && echo "✓ Ex2 : hostname -I renvoie une IP" || { echo "✗ hostname -I vide"; fail=1; }
docker compose exec -T vuln-host ss -tulpn | grep -q ":22" && echo "✓ Ex2 : ss -tulpn liste les ports (22/80/3306…)" || { echo "✗ ss -tulpn vide"; fail=1; }
docker compose exec -T vuln-host bash -c 'ps -ef | grep -qE "nginx|sshd"' && echo "✓ Ex2 : services actifs identifiés (adaptation ps/init.d)" || { echo "✗ services non identifiés"; fail=1; }
docker compose exec -T vuln-host bash -c 'cd /tmp && sha256sum -c somme.sha256 2>/dev/null | grep -q ": OK"' && echo "✓ Ex4 : sha256sum -c → OK (intégrité vérifiée)" || { echo "✗ vérification sha256sum échouée"; fail=1; }

echo
if [ "$fail" -eq 0 ]; then
  echo "✅ Ch40 corrigés : VALIDÉ"
else
  echo "❌ Ch40 corrigés : ÉCHEC"
  exit 1
fi
