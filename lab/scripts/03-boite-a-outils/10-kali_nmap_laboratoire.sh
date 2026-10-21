#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  Chapitre  : 10 — Outils de reconnaissance et d'analyse
#  Exercice  : 1 (Débutant) — Cartographier votre laboratoire avec Nmap
#  Version   : kali-rolling 2026.2 (nmap 7.99)
#  Exécution : bash scripts/03-boite-a-outils/10-kali_nmap_laboratoire.sh
#              (depuis lab/ ; nécessite `make up-pentest`)
#  Statut    : VALIDÉ (2026-08-11)
#
#  Adaptation Docker : le manuel scanne 10.77.0.0/24 (VirtualBox).
#  Ici on scanne le /24 réel des cibles du lab (seclab-internal est en
#  /16 mais seules quelques adresses 172.21.0.x sont utilisées).
# ─────────────────────────────────────────────────────────────
set -euo pipefail
cd "$(dirname "$0")/../.."   # → lab/

echo "== Ch10 Ex1 — Cartographie du laboratoire avec Nmap =="
fail=0

subnet=$(docker network inspect security-ebook-lab_seclab-internal --format '{{range .IPAM.Config}}{{.Subnet}}{{end}}')
# /16 → /24 (premiers 3 octets) pour un scan rapide et ciblé
net24=$(echo "$subnet" | sed -E 's#([0-9]+\.[0-9]+\.[0-9]+)\.[0-9]+/[0-9]+#\1.0/24#')
echo "sous-réseau interne : $subnet → scan du /24 : $net24"

echo
echo "--- 1. Découverte d'hôtes (nmap -sn) ---"
out=$(docker compose exec -T kali nmap -sn "$net24" 2>&1)
echo "$out" | grep -E "Nmap scan report|Host is up" | head -12
echo "$out" | grep -q "vuln-host" && echo "✓ vuln-host découvert" || { echo "✗ vuln-host non découvert"; fail=1; }
echo "$out" | grep -q "vuln-api" && echo "✓ vuln-api découvert" || { echo "✗ vuln-api non découvert"; fail=1; }

echo
echo "--- 2. Scan de la cible avec versions (nmap -sV) ---"
out=$(docker compose exec -T kali nmap -sV -p 1-10000 vuln-host -oN /tmp/scan-cible.txt 2>&1)
echo "$out" | grep -E "PORT|/tcp" | head -8
echo "$out" | grep -qE "22/tcp.*ssh.*OpenSSH" && echo "✓ SSH/OpenSSH identifié" || { echo "✗ SSH non identifié"; fail=1; }
echo "$out" | grep -qE "80/tcp.*http.*nginx" && echo "✓ HTTP/nginx identifié" || { echo "✗ HTTP non identifié"; fail=1; }
echo "$out" | grep -qE "3306/tcp.*mysql" && echo "✓ MySQL/MariaDB identifié" || { echo "✗ MySQL non identifié"; fail=1; }

echo
echo "--- 3. Lecture du rapport enregistré ---"
out=$(docker compose exec -T kali cat /tmp/scan-cible.txt)
echo "$out" | grep -q "Nmap scan report for vuln-host" && echo "✓ rapport -oN enregistré et lisible" || { echo "✗ rapport absent"; fail=1; }

echo
if [ "$fail" -eq 0 ]; then
  echo "✅ Ch10 Ex1 : VALIDÉ"
else
  echo "❌ Ch10 Ex1 : ÉCHEC"
  exit 1
fi
