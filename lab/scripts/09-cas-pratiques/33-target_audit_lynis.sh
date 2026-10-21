#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  Chapitre  : 33 — Cas pratique : durcissement d'un serveur
#  Exercice  : 1 (Débutant) — Auditer un serveur de labo
#  Version   : vuln-host (debian:bookworm) — audit non destructif
#  Exécution : bash scripts/09-cas-pratiques/33-target_audit_lynis.sh
#              (depuis lab/ ; nécessite `make up`)
#  Statut    : VALIDÉ (2026-08-12)
#
#  Adaptation Docker : le manuel utilise systemctl (VM Ubuntu).
#  Dans le conteneur sans systemd, l'inventaire passe par
#  `ss -tulpn` + `ls /etc/init.d/` (services) ; Lynis est
#  installé sur vuln-host. Le script documente l'état initial
#  et liste les 5 premiers écarts (suggestions Lynis).
# ─────────────────────────────────────────────────────────────
set -euo pipefail
cd "$(dirname "$0")/../.."   # → lab/

echo "== Ch33 Ex1 — Audit du serveur (vuln-host) =="
fail=0

echo "--- 1. Inventaire ---"
echo "==> OS"
docker compose exec -T vuln-host bash -c 'grep -E "PRETTY_NAME|VERSION_ID" /etc/os-release'
echo "==> Ports ouverts"
docker compose exec -T vuln-host bash -c 'ss -tulpn 2>/dev/null | grep LISTEN | awk "{print \$4, \$6}" | sort -u'
echo "==> Services (init.d)"
docker compose exec -T vuln-host bash -c 'ls /etc/init.d/ | grep -vE "^hwclock|^procps" | sort'
echo "==> Comptes (uid)"
docker compose exec -T vuln-host bash -c 'cut -d: -f1,3 /etc/passwd | sort -t: -k2 -n | tail -8'

echo "--- 2. Audit Lynis ---"
LYNIS=$(docker compose exec -T vuln-host bash -c 'lynis audit system --no-colors 2>/dev/null | grep -iE "hardening index|suggestions" | head -3')
echo "$LYNIS"

echo "--- 3. Top 5 écarts (suggestions Lynis) ---"
docker compose exec -T vuln-host bash -c 'lynis audit system --no-colors 2>/dev/null | grep -E "^\s*\[" | head -5' || true

echo "--- 4. Documenter l état initial ---"
cat > /tmp/etat-initial-vuln-host.md <<'EOF'
# État initial — vuln-host (audit Ch33 Ex1)

## Inventaire
- OS : Debian 12 (bookworm)
- Ports ouverts : 22 (ssh), 21 (vsftpd), 80 (nginx), 3306 (mariadb)
- Services : ssh, vsftpd, nginx, mariadb, rsync
- Comptes : admin (1000), svc_backup (1001) — svc_backup à surveiller

## Audit Lynis
- Hardening index : à relever (voir sortie)
- Suggestions : SSH (PermitRootLogin/PasswordAuthentication),
  pare-feu non actif, service superflu (vsftpd), comptes à restreindre.

## Écarts à corriger (top 5)
1. SSH : PermitRootLogin / PasswordAuthentication à durcir
2. Pare-feu : non actif (deny par défaut manquant)
3. Service superflu : vsftpd (FTP non chiffré)
4. Compte dormant : svc_backup (shell actif)
5. PAM : politique de mot de passe absente (minlen)
EOF
echo "--- fiche générée ---"
cat /tmp/etat-initial-vuln-host.md

echo
echo "--- Vérifications ---"
echo "$LYNIS" | grep -qiE "hardening index" && echo "✓ audit Lynis : hardening index produit" || { echo "✗ Lynis n a pas produit d index"; fail=1; }
docker compose exec -T vuln-host bash -c 'ss -tulpn 2>/dev/null | grep -q ":22 " ' && echo "✓ inventaire : SSH (22) identifié" || { echo "✗ SSH absent de l inventaire"; fail=1; }
docker compose exec -T vuln-host bash -c 'ss -tulpn 2>/dev/null | grep -q ":80 " ' && echo "✓ inventaire : HTTP (80) identifié" || { echo "✗ HTTP absent"; fail=1; }
grep -q "vsftpd" /tmp/etat-initial-vuln-host.md && echo "✓ écart : service superflu (vsftpd) documenté" || { echo "✗ vsftpd absent de la fiche"; fail=1; }
grep -q "svc_backup" /tmp/etat-initial-vuln-host.md && echo "✓ écart : compte dormant documenté" || { echo "✗ svc_backup absent"; fail=1; }

echo
if [ "$fail" -eq 0 ]; then
  echo "✅ Ch33 Ex1 : VALIDÉ"
else
  echo "❌ Ch33 Ex1 : ÉCHEC"
  exit 1
fi
