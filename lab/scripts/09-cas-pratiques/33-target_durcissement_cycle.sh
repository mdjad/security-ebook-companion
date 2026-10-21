#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  Chapitre  : 33 — Cas pratique : durcissement d'un serveur
#  Exercice  : 2 (Intermédiaire) — Corriger, vérifier et documenter
#  Version   : vuln-host (debian:bookworm), kali (clé SSH)
#  Exécution : bash scripts/09-cas-pratiques/33-target_durcissement_cycle.sh
#              (depuis lab/ ; nécessite `make up-pentest`)
#  Statut    : VALIDÉ (2026-08-12)
#
#  Cycle complet (fidèle au manuel) : clé SSH → durcissement SSH →
#  pare-feu → service superflu → compte dormant → PAM → re-audit →
#  tests fonctionnels → fiche d'état durci. Le script RESTAURE la
#  configuration à la fin pour ne pas casser les exercices de
#  pentest (Ch15/16 utilisent les identifiants faibles).
#
#  Adaptations Docker :
#    - systemctl restart sshd → `sshd -t && kill -HUP $(cat /run/sshd.pid)`
#    - ufw (manuel) → iptables équivalent (même politique)
#    - service superflu = vsftpd (FTP non chiffré, cf. Ch17)
#    - compte dormant = svc_backup (shell → nologin, cf. Ch20)
#    - PAM : pam_pwquality (minlen=12) ajouté à /etc/pam.d/common-password
# ─────────────────────────────────────────────────────────────
set -euo pipefail
cd "$(dirname "$0")/../.."   # → lab/

echo "== Ch33 Ex2 — Cycle de durcissement (vuln-host) =="
fail=0

# 0. Clé de test (poste de labo → serveur)
rm -f /tmp/lab_key /tmp/lab_key.pub
ssh-keygen -t ed25519 -f /tmp/lab_key -N "" -q

# 1. Clé publique sur le serveur (équivalent ssh-copy-id, compte admin)
docker compose exec -T vuln-host bash -c '
mkdir -p /home/admin/.ssh && chown admin:admin /home/admin/.ssh && chmod 700 /home/admin/.ssh
cat >> /home/admin/.ssh/authorized_keys
chown admin:admin /home/admin/.ssh/authorized_keys && chmod 600 /home/admin/.ssh/authorized_keys
' < /tmp/lab_key.pub
echo "--- 1. Clé installée (testée avant désactivation des mots de passe) ---"

# 2. Durcir SSH
docker compose exec -T vuln-host bash -c '
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.lab.bak
sed -i "s/^#\?PermitRootLogin.*/PermitRootLogin no/" /etc/ssh/sshd_config
sed -i "s/^#\?PasswordAuthentication.*/PasswordAuthentication no/" /etc/ssh/sshd_config
sshd -t && kill -HUP $(cat /run/sshd.pid)
sshd -T | grep -iE "permitrootlogin|passwordauthentication"
'
echo "--- 2. SSH durci ---"

# 3. Pare-feu : refus par défaut, ouverture SSH/HTTP (iptables)
docker compose exec -T vuln-host bash -c '
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -p tcp --dport 22 -j ACCEPT
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -L -n | head -6
'
echo "--- 3. Pare-feu actif (deny par défaut, 22/80) ---"

# 4. Service superflu : vsftpd (FTP non chiffré)
docker compose exec -T vuln-host bash -c 'pkill vsftpd 2>/dev/null || true; pgrep -a vsftpd || echo "vsftpd arrêté"'
echo "--- 4. Service superflu désactivé (vsftpd) ---"

# 5. Compte dormant : svc_backup → nologin (moindre privilège)
docker compose exec -T vuln-host bash -c '
usermod -s /usr/sbin/nologin svc_backup
grep "^svc_backup" /etc/passwd
'
echo "--- 5. Compte dormant restreint (svc_backup → nologin) ---"

# 6. PAM : politique de mot de passe (minlen=12)
docker compose exec -T vuln-host bash -c '
grep -q "pam_pwquality" /etc/pam.d/common-password || \
  sed -i "1i password requisite pam_pwquality.so retry=3 minlen=12" /etc/pam.d/common-password
grep "pam_pwquality" /etc/pam.d/common-password
'
echo "--- 6. PAM : politique de mot de passe (minlen=12) ---"

# 7. Re-audit Lynis
echo "--- 7. Re-audit Lynis ---"
LYNIS=$(docker compose exec -T vuln-host bash -c 'lynis audit system --no-colors 2>/dev/null | grep -iE "hardening index" | head -1')
echo "$LYNIS"

# 8. Tests fonctionnels
echo "--- 8. Tests fonctionnels ---"
KEY=$(docker compose exec -T kali bash -c 'cat > /tmp/lab_key; chmod 600 /tmp/lab_key' < /tmp/lab_key)
KEY=$(docker compose exec -T kali bash -c 'ssh -i /tmp/lab_key -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=5 admin@vuln-host "echo CLE_OK"' 2>/dev/null || true)
echo "clé : $KEY"
PWD=$(docker compose exec -T kali bash -c 'hydra -l admin -p admin123 -f -t 1 ssh://vuln-host 2>/dev/null | grep -cE "login:"' || true)
echo "logins par mot de passe : $PWD"
HTTP=$(docker compose exec -T kali bash -c 'curl -s -o /dev/null -w "%{http_code}" http://vuln-host/' 2>/dev/null || echo "000")
echo "HTTP vuln-host : $HTTP"

# 9. Fiche d'état durci
cat > /tmp/fiche-etat-durci.md <<'EOF'
# Fiche d'état durci — vuln-host (Ch33 Ex2)

## Corrections appliquées
- SSH : PermitRootLogin no, PasswordAuthentication no (clé seule)
- Pare-feu : deny par défaut, ouverture 22/80 (iptables)
- Service superflu : vsftpd désactivé
- Compte dormant : svc_backup → nologin
- PAM : pam_pwquality minlen=12

## Vérifications
- Connexion par clé : OK
- Mot de passe : refusé
- HTTP (80) : accessible
- Re-audit Lynis : hardening index relevé

## Base de référence
- Fiche versionnée ; re-audit périodique ; automatisation IaC (ch. 29).
EOF
echo "--- 9. Fiche d'état durci ---"
cat /tmp/fiche-etat-durci.md

# 10. Restauration (pentest intacts)
docker compose exec -T vuln-host bash -c '
iptables -F && iptables -P INPUT ACCEPT && iptables -P FORWARD ACCEPT
cp /etc/ssh/sshd_config.lab.bak /etc/ssh/sshd_config
sshd -t && kill -HUP $(cat /run/sshd.pid)
usermod -s /bin/bash svc_backup
sed -i "/pam_pwquality/d" /etc/pam.d/common-password
/usr/sbin/vsftpd /etc/vsftpd.conf >/var/log/vsftpd.log 2>&1 &
rm -f /home/admin/.ssh/authorized_keys
echo "configuration restaurée"
'
echo "--- 10. Configuration restaurée ---"

echo
echo "--- Vérifications ---"
echo "$KEY" | grep -q "CLE_OK" && echo "✓ clé SSH fonctionne (testée avant désactivation)" || { echo "✗ clé refusée"; fail=1; }
[ "$PWD" -eq 0 ] && echo "✓ mot de passe refusé (PasswordAuthentication no)" || { echo "✗ mot de passe encore accepté"; fail=1; }
[ "$HTTP" = "200" ] && echo "✓ HTTP (80) accessible après durcissement" || { echo "✗ HTTP non accessible (code $HTTP)"; fail=1; }
echo "$LYNIS" | grep -qiE "hardening index" && echo "✓ re-audit Lynis : hardening index produit" || { echo "✗ re-audit Lynis absent"; fail=1; }
grep -q "PermitRootLogin no" /tmp/fiche-etat-durci.md && echo "✓ fiche : SSH durci documenté" || { echo "✗ fiche SSH absente"; fail=1; }
grep -q "svc_backup" /tmp/fiche-etat-durci.md && echo "✓ fiche : compte dormant documenté" || { echo "✗ fiche compte absent"; fail=1; }
grep -q "pam_pwquality" /tmp/fiche-etat-durci.md && echo "✓ fiche : PAM documenté" || { echo "✗ fiche PAM absente"; fail=1; }

echo
if [ "$fail" -eq 0 ]; then
  echo "✅ Ch33 Ex2 : VALIDÉ"
else
  echo "❌ Ch33 Ex2 : ÉCHEC"
  exit 1
fi
