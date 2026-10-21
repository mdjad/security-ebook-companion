#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  Chapitre  : 07 — Réseaux et protocoles
#  Exercice  : 1 (Débutant) — Lire le trafic local avec tcpdump
#  Version   : kali-rolling 2026.2 (tcpdump 4.99, curl 8.x)
#  Exécution : bash scripts/02-socle-technique/07-kali_tcpdump_http.sh
#              (depuis lab/ ; nécessite `make up-pentest`)
#  Statut    : VALIDÉ (2026-08-11)
#
#  Adaptation Docker : Kali est relié à plusieurs réseaux ; l'interface
#  utilisée pour joindre la cible varie. Capturer sur `any` évite de figer
#  eth0/eth1. Le résolveur Docker (127.0.0.11) répond en userspace : la
#  résolution est vérifiée séparément, puis le trafic HTTP vers vuln-host
#  valide la capture TCP sans dépendre d'un accès Internet.
# ─────────────────────────────────────────────────────────────
set -euo pipefail
cd "$(dirname "$0")/../.."   # → lab/

echo "== Ch07 Ex1 — Capture tcpdump d'une requête HTTP (dans kali) =="
fail=0

out=$(docker compose exec -T kali bash -c '
  echo "DNS vuln-host -> $(dig +short vuln-host | head -1)"
  timeout 10 tcpdump -i any -nn -c 8 -w /tmp/web.pcap "tcp port 80" 2>/dev/null &
  TPID=$!
  sleep 1
  curl -s --max-time 5 http://vuln-host/ -o /dev/null
  wait $TPID || true
  echo "--- analyse ---"
  tcpdump -r /tmp/web.pcap -nn -A 2>/dev/null | head -40
')
echo "$out"

echo "$out" | grep -qE 'DNS vuln-host -> [0-9]+' && echo "✓ résolution DNS de la cible" || { echo "✗ résolution DNS en échec"; fail=1; }
echo "$out" | grep -qE "Flags \[S\]" && echo "✓ SYN (poignée de main TCP) capturé" || { echo "✗ pas de SYN"; fail=1; }
echo "$out" | grep -qE "Flags \[S\.\]" && echo "✓ SYN-ACK capturé" || { echo "✗ pas de SYN-ACK"; fail=1; }
echo "$out" | grep -qE "Flags \[\.\]" && echo "✓ ACK capturé" || { echo "✗ pas d'ACK"; fail=1; }
echo "$out" | grep -q "GET / HTTP/" && echo "✓ requête HTTP capturée" || { echo "✗ pas de requête HTTP"; fail=1; }

echo
if [ "$fail" -eq 0 ]; then
  echo "✅ Ch07 Ex1 : VALIDÉ"
else
  echo "❌ Ch07 Ex1 : ÉCHEC"
  exit 1
fi
