#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  Chapitre  : 21 — Défense réseau, segmentation et Zero Trust
#  Exercice  : 1 (Débutant) — Défense réseau de base en laboratoire
#  Version   : vuln-host (iptables, NET_ADMIN) + kali (nc)
#  Exécution : bash scripts/06-defense-soc/21-host_defense_reseau.sh
#              (depuis lab/ ; nécessite `make up-pentest`)
#  Statut    : VALIDÉ (2026-08-12)
#
#  Adaptation Docker : le manuel autorise SSH depuis le sous-réseau
#  de labo (10.77.0.0/24) → ici le sous-réseau interne réel
#  (seclab-internal). La politique est appliquée puis RESTAURÉE en
#  fin de script pour ne pas casser les exercices de pentest.
# ─────────────────────────────────────────────────────────────
set -euo pipefail
cd "$(dirname "$0")/../.."   # → lab/

echo "== Ch21 Ex1 — Défense réseau (iptables) =="
fail=0

# Sous-réseau interne réel (équivalent 10.77.0.0/24 du manuel)
SUBNET=$(docker network inspect security-ebook-lab_seclab-internal -f '{{range .IPAM.Config}}{{.Subnet}}{{end}}')
echo "sous-réseau interne : $SUBNET"

out=$(docker compose exec -T vuln-host bash -c "
set -e
echo '--- 1. Politique par défaut stricte ---'
iptables -P INPUT DROP
iptables -P FORWARD DROP

echo '--- 2. Trafic déjà établi et loopback ---'
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

echo '--- 3. Ouvertures explicites : SSH (poste de labo) et HTTPS ---'
iptables -A INPUT -p tcp --dport 22 -s $SUBNET -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -j ACCEPT

echo '--- 4. Vérification ---'
iptables -L -n -v | head -10
")

echo "--- depuis le poste d attaque (kali) ---"
fw=$(docker compose exec -T kali bash -c '
nc -z -w 2 vuln-host 22 && echo "22 SSH ouvert"
! nc -z -w 2 vuln-host 80 && echo "80 HTTP fermé"
! nc -z -w 2 vuln-host 3306 && echo "3306 MySQL fermé"
')
echo "$fw"

# Restauration (pentest intacts)
docker compose exec -T vuln-host bash -c '
iptables -F && iptables -P INPUT ACCEPT && iptables -P FORWARD ACCEPT
echo "politique restaurée (ACCEPT)"
'

echo
echo "--- Vérifications ---"
echo "$out" | grep -q "policy DROP" && echo "✓ politique par défaut : DROP (INPUT + FORWARD)" || { echo "✗ politique DROP absente"; fail=1; }
echo "$out" | grep -q "dpt:22" && echo "✓ ouverture SSH (22) depuis le sous-réseau de labo" || { echo "✗ règle SSH absente"; fail=1; }
echo "$out" | grep -q "dpt:443" && echo "✓ ouverture HTTPS (443)" || { echo "✗ règle HTTPS absente"; fail=1; }
echo "$fw" | grep -q "22 SSH ouvert" && echo "✓ depuis kali : SSH joignable" || { echo "✗ SSH bloqué"; fail=1; }
echo "$fw" | grep -q "80 HTTP fermé" && echo "✓ depuis kali : HTTP fermé (deny par défaut)" || { echo "✗ HTTP encore ouvert"; fail=1; }
echo "$fw" | grep -q "3306 MySQL fermé" && echo "✓ depuis kali : MySQL fermé" || { echo "✗ MySQL encore ouvert"; fail=1; }

echo
if [ "$fail" -eq 0 ]; then
  echo "✅ Ch21 Ex1 : VALIDÉ"
else
  echo "❌ Ch21 Ex1 : ÉCHEC"
  exit 1
fi
