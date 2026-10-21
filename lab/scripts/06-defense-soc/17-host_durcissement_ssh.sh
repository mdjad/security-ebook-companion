#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  Chapitre  : 17 — Durcissement des systèmes
#  Exercice  : 2 (Intermédiaire) — Durcissement SSH + pare-feu
#  Version   : vuln-host (debian:bookworm), kali (hydra, ssh)
#  Exécution : bash scripts/06-defense-soc/17-host_durcissement_ssh.sh
#              (depuis lab/ ; nécessite `make up-pentest`)
#  Statut    : VALIDÉ (2026-08-12)
#
#  Déroulé (fidèle au manuel) :
#    1. Clé publique installée sur le serveur (ssh-copy-id équivalent)
#    2. Durcissement SSH : PermitRootLogin no + PasswordAuthentication no
#    3. Pare-feu : refus par défaut, ouverture SSH/HTTPS
#    4. Audit Lynis (hardening index)
#  Le script RESTAURE la configuration à la fin pour ne pas casser
#  les exercices de pentest (Ch15/16 utilisent les identifiants
#  faibles admin/admin123).
#
#  Adaptations Docker :
#    - systemctl restart sshd → `sshd -t && kill -HUP $(cat /run/sshd.pid)`
#    - ufw (manuel) → iptables équivalent (ufw est un wrapper d'iptables ;
#      même politique : deny incoming, allow 22/443). Documenté VALIDATION.md.
#    - La vérification « mot de passe refusé » passe par hydra (déjà
#      installé sur kali) : avant = login trouvé, après = aucun.
# ─────────────────────────────────────────────────────────────
set -euo pipefail
cd "$(dirname "$0")/../.."   # → lab/

echo "== Ch17 Ex2 — Durcissement SSH + pare-feu =="
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

# 2. Avant durcissement : le mot de passe fonctionne (hydra)
echo "--- avant durcissement : hydra (mot de passe admin/admin123) ---"
before=$(docker compose exec -T kali bash -c 'hydra -l admin -p admin123 -f -t 1 ssh://vuln-host 2>/dev/null | grep -cE "login:"' || true)
echo "logins trouvés avant : $before"

# 3. Durcir SSH
docker compose exec -T vuln-host bash -c '
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.lab.bak
sed -i "s/^#\?PermitRootLogin.*/PermitRootLogin no/" /etc/ssh/sshd_config
sed -i "s/^#\?PasswordAuthentication.*/PasswordAuthentication no/" /etc/ssh/sshd_config
sshd -t && kill -HUP $(cat /run/sshd.pid)
echo "--- config effective ---"
sshd -T | grep -iE "permitrootlogin|passwordauthentication"
'

# 4. Pare-feu : refus par défaut, ouverture SSH/HTTPS (iptables)
docker compose exec -T vuln-host bash -c '
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -p tcp --dport 22 -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -j ACCEPT
echo "--- politique active ---"
iptables -L -n | head -8
'

# 5. Vérifications depuis le poste d attaque (kali)
echo "--- après durcissement : connexion par clé (admin) ---"
key=$(docker compose exec -T kali bash -c 'cat > /tmp/lab_key; chmod 600 /tmp/lab_key' < /tmp/lab_key)
key=$(docker compose exec -T kali bash -c 'ssh -i /tmp/lab_key -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=5 admin@vuln-host "echo KEY_OK"' 2>/dev/null || true)
echo "résultat clé : $key"

echo "--- après durcissement : hydra (mot de passe refusé) ---"
after=$(docker compose exec -T kali bash -c 'hydra -l admin -p admin123 -f -t 1 ssh://vuln-host 2>/dev/null | grep -cE "login:"' || true)
echo "logins trouvés après : $after"

echo "--- pare-feu : ports depuis kali ---"
fw=$(docker compose exec -T kali bash -c '
nc -z -w 2 vuln-host 22 && echo "22 ouvert"
! nc -z -w 2 vuln-host 80 && echo "80 fermé"
! nc -z -w 2 vuln-host 3306 && echo "3306 fermé"
')
echo "$fw"

# 6. Audit Lynis
echo "--- audit Lynis ---"
lynis=$(docker compose exec -T vuln-host bash -c 'lynis audit system --no-colors 2>/dev/null | grep -iE "hardening index|suggestions" | head -3')
echo "$lynis"

# 7. Restauration (pentest intacts)
docker compose exec -T vuln-host bash -c '
iptables -F && iptables -P INPUT ACCEPT && iptables -P FORWARD ACCEPT
cp /etc/ssh/sshd_config.lab.bak /etc/ssh/sshd_config
sshd -t && kill -HUP $(cat /run/sshd.pid)
rm -f /home/admin/.ssh/authorized_keys
echo "configuration restaurée"
'

echo
echo "--- Vérifications ---"
[ "$before" -ge 1 ] && echo "✓ avant : mot de passe admin/admin123 accepté (hydra)" || { echo "✗ hydra avant : aucun login"; fail=1; }
echo "$key" | grep -q "KEY_OK" && echo "✓ après : connexion par clé fonctionne" || { echo "✗ clé refusée après durcissement"; fail=1; }
[ "$after" -eq 0 ] && echo "✓ après : mot de passe refusé (PasswordAuthentication no)" || { echo "✗ mot de passe encore accepté"; fail=1; }
echo "$fw" | grep -q "22 ouvert" && echo "✓ pare-feu : SSH (22) ouvert" || { echo "✗ SSH bloqué"; fail=1; }
echo "$fw" | grep -q "80 fermé" && echo "✓ pare-feu : HTTP (80) fermé (deny par défaut)" || { echo "✗ HTTP encore ouvert"; fail=1; }
echo "$fw" | grep -q "3306 fermé" && echo "✓ pare-feu : MySQL (3306) fermé" || { echo "✗ MySQL encore ouvert"; fail=1; }
echo "$lynis" | grep -qiE "hardening index" && echo "✓ audit Lynis : hardening index produit" || { echo "✗ Lynis n a pas produit d index"; fail=1; }

echo
if [ "$fail" -eq 0 ]; then
  echo "✅ Ch17 Ex2 : VALIDÉ"
else
  echo "❌ Ch17 Ex2 : ÉCHEC"
  exit 1
fi
