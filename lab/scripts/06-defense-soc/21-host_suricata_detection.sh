#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  Chapitre  : 21 — Défense réseau, segmentation et Zero Trust
#  Exercice  : 2 (Intermédiaire) — Surveiller et détecter avec Suricata
#  Version   : jasonish/suricata 8.0.6 (service seclab-suricata)
#  Exécution : bash scripts/06-defense-soc/21-host_suricata_detection.sh
#              (depuis lab/ ; nécessite `make up-pentest`)
#  Statut    : VALIDÉ (2026-08-12)
#
#  Déroulé (fidèle au manuel) :
#    1. Test de configuration (suricata -T)
#    2. Suricata en mode IDS sur l'interface
#    3. Génération de trafic de test (curl, ping, nc ssh)
#    4. Consultation des alertes (fast.log)
#    5. Confirmation par une capture tcpdump ciblée
#
#  Adaptation Docker : règles locales (SIDs 9000001-9000003) pour
#  des alertes déterministes sans téléchargement ET (réseau interne
#  sans Internet). Le trafic est généré depuis le conteneur suricata
#  lui-même, comme le manuel (« depuis la même machine »).
# ─────────────────────────────────────────────────────────────
set -euo pipefail
cd "$(dirname "$0")/../.."   # → lab/

echo "== Ch21 Ex2 — Suricata + tcpdump =="
fail=0

out=$(docker compose exec -T suricata bash -c '
set -e
echo "--- 1. Test de configuration ---"
suricata -T -c /etc/suricata/suricata.yaml -S /etc/suricata/local.rules 2>&1 | grep -iE "successfully loaded|error" | head -2

echo "--- 2. Lancement de Suricata en mode IDS ---"
rm -f /var/log/suricata/fast.log
suricata -c /etc/suricata/suricata.yaml -S /etc/suricata/local.rules -i eth0 >/var/log/suricata-run.log 2>&1 &
SPID=$!
sleep 6

echo "--- 3. Génération de trafic de test ---"
curl -s -o /dev/null http://vuln-api:5000/health && echo "curl vers vuln-api OK"
ping -c 2 dvwa >/dev/null 2>&1 && echo "ping vers dvwa OK"
nc -z -w 2 vuln-host 22 && echo "connexion SSH (nc) OK"
sleep 3
kill $SPID 2>/dev/null || true
wait $SPID 2>/dev/null || true

echo "--- 4. Alertes (fast.log) ---"
grep -E "9000001|9000002|9000003" /var/log/suricata/fast.log | head -6

echo "--- 5. Capture tcpdump ciblée ---"
tcpdump -i eth0 -nn -c 20 -w /tmp/test.pcap >/dev/null 2>&1 &
TPID=$!
sleep 1
curl -s -o /dev/null http://vuln-api:5000/health
sleep 2
kill $TPID 2>/dev/null || true
wait $TPID 2>/dev/null || true
tcpdump -r /tmp/test.pcap -nn 2>/dev/null | head -3
')
echo "$out"

echo
echo "--- Vérifications ---"
echo "$out" | grep -q "successfully loaded" && echo "✓ configuration Suricata valide (suricata -T)" || { echo "✗ test de config en échec"; fail=1; }
echo "$out" | grep -q "9000001" && echo "✓ alerte HTTP (9000001) : curl vers vuln-api détecté" || { echo "✗ alerte HTTP absente"; fail=1; }
echo "$out" | grep -q "9000002" && echo "✓ alerte ICMP (9000002) : ping détecté" || { echo "✗ alerte ICMP absente"; fail=1; }
echo "$out" | grep -q "9000003" && echo "✓ alerte SSH (9000003) : connexion port 22 détectée" || { echo "✗ alerte SSH absente"; fail=1; }
echo "$out" | grep -qE "IP|ARP" && echo "✓ capture tcpdump lue (tcpdump -r)" || { echo "✗ capture tcpdump illisible"; fail=1; }

echo
if [ "$fail" -eq 0 ]; then
  echo "✅ Ch21 Ex2 : VALIDÉ"
else
  echo "❌ Ch21 Ex2 : ÉCHEC"
  exit 1
fi
