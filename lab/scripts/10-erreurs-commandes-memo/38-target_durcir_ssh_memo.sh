#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  Chapitre  : 38 — 200 commandes de sécurité
#  Exercice  : 2 (Intermédiaire) — Durcir l'accès SSH
#  Version   : vuln-host (config minimale SSH)
#  Exécution : bash scripts/10-erreurs-commandes-memo/38-target_durcir_ssh_memo.sh
#              (depuis lab/ ; nécessite `make up`)
#  Statut    : VALIDÉ (2026-08-12)
#
#  Adaptation Docker : systemctl reload sshd → `sshd -t && kill -HUP
#  $(cat /run/sshd.pid)`. La clé est testée avant de fermer le mot
#  de passe (règle du manuel). La configuration est restaurée à la
#  fin pour ne pas casser les exercices de pentest.
# ─────────────────────────────────────────────────────────────
set -euo pipefail
cd "$(dirname "$0")/../.."   # → lab/

echo "== Ch38 Ex2 — Durcir l'accès SSH (memo) =="
fail=0

# 0. Clé de test
rm -f /tmp/memo_key /tmp/memo_key.pub
ssh-keygen -t ed25519 -f /tmp/memo_key -N "" -q

# 1. Clé sur le serveur (testée avant fermeture du mot de passe)
docker compose exec -T vuln-host bash -c '
mkdir -p /home/admin/.ssh && chmod 700 /home/admin/.ssh
cat >> /home/admin/.ssh/authorized_keys
chown -R admin:admin /home/admin/.ssh && chmod 600 /home/admin/.ssh/authorized_keys
' < /tmp/memo_key.pub
echo "--- 1. Clé installée ---"

# 2. Config minimale : PermitRootLogin no + PasswordAuthentication no
docker compose exec -T vuln-host bash -c '
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.memo.bak
sed -i "s/^#\?PermitRootLogin.*/PermitRootLogin no/" /etc/ssh/sshd_config
sed -i "s/^#\?PasswordAuthentication.*/PasswordAuthentication no/" /etc/ssh/sshd_config
sshd -t && echo "sshd -t : syntaxe OK" && kill -HUP $(cat /run/sshd.pid)
'
echo "--- 2. Config appliquée ---"

# 3. Vérifications (avant restauration)
echo "--- 3. Vérifications ---"
CFG=$(docker compose exec -T vuln-host bash -c 'sshd -T | grep -iE "permitrootlogin|passwordauthentication"')
echo "$CFG"
KEY=$(docker compose exec -T kali bash -c 'cat > /tmp/memo_key; chmod 600 /tmp/memo_key' < /tmp/memo_key)
KEY=$(docker compose exec -T kali bash -c 'ssh -i /tmp/memo_key -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=5 admin@vuln-host "echo CLE_OK"' 2>/dev/null || true)
echo "clé : $KEY"
PORT=$(docker compose exec -T vuln-host bash -c 'ss -tln | grep ":22" | head -1')
echo "port 22 : $PORT"

# 4. Restauration
docker compose exec -T vuln-host bash -c '
cp /etc/ssh/sshd_config.memo.bak /etc/ssh/sshd_config
sshd -t && kill -HUP $(cat /run/sshd.pid)
rm -f /home/admin/.ssh/authorized_keys
echo "configuration restaurée"
'

echo
echo "--- Vérifications ---"
echo "$KEY" | grep -q "CLE_OK" && echo "✓ clé SSH fonctionne (testée avant fermeture)" || { echo "✗ clé refusée"; fail=1; }
echo "$CFG" | grep -qi "permitrootlogin no" && echo "✓ PermitRootLogin no effectif" || { echo "✗ PermitRootLogin non appliqué"; fail=1; }
echo "$CFG" | grep -qi "passwordauthentication no" && echo "✓ PasswordAuthentication no effectif" || { echo "✗ PasswordAuthentication non appliqué"; fail=1; }
echo "$PORT" | grep -q ":22" && echo "✓ port 22 toujours en écoute" || { echo "✗ port 22 fermé"; fail=1; }

echo
if [ "$fail" -eq 0 ]; then
  echo "✅ Ch38 Ex2 : VALIDÉ"
else
  echo "❌ Ch38 Ex2 : ÉCHEC"
  exit 1
fi
