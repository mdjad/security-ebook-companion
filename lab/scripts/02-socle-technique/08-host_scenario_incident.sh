#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  Chapitre  : 08 — Environnement de laboratoire
#  Exercice  : 2 (Intermédiaire) — Reproduire un scénario d'incident en conteneurs
#  Version   : Docker 29.6.2 (Apple Silicon)
#  Exécution : bash scripts/02-socle-technique/08-host_scenario_incident.sh
#              (depuis lab/ ; nécessite Docker, indépendant du compose)
#  Statut    : VALIDÉ (2026-08-11)
#
#  Reprend le scénario du manuel : réseau interne, web + base de
#  données, observation avec netshoot, nettoyage. Les noms sont
#  préfixés (incident-*) pour ne pas entrer en conflit avec le lab.
# ─────────────────────────────────────────────────────────────
set -euo pipefail
cd "$(dirname "$0")/../.."   # → lab/

NET=incident-net
WEB=incident-web
DB=incident-db

echo "== Ch08 Ex2 — Scénario d'incident en conteneurs =="
fail=0

cleanup() {
  docker rm -f incident-netshoot "$WEB" "$DB" >/dev/null 2>&1 || true
  docker network rm "$NET" >/dev/null 2>&1 || true
}
trap cleanup EXIT

echo
echo "--- 1. Réseau interne ---"
docker network create --internal "$NET" >/dev/null
echo "✓ réseau $NET créé (--internal, aucun egress)"

echo
echo "--- 2. Cible web ---"
docker run -d --name "$WEB" --network "$NET" nginx:alpine >/dev/null
echo "✓ conteneur $WEB lancé (nginx)"

echo
echo "--- 3. Base de données (port non exposé hors réseau) ---"
docker run -d --name "$DB" --network "$NET" -e MYSQL_ROOT_PASSWORD=secretlab mariadb:11 >/dev/null
echo "✓ conteneur $DB lancé (mariadb, aucun port publié)"

echo
echo "--- 4. Observation avec netshoot (tcpdump) ---"
# netshoot capture sur eth0 ; on génère du trafic depuis netshoot
# lui-même (curl vers le web et la base), puis on lit le pcap.
# Filtre tcpdump sur les ports 80/3306 : le bruit ARP/IPv6 du réseau
# interne ne doit pas remplir la capture avant le trafic applicatif.
docker run -d --name incident-netshoot --network "$NET" --cap-add NET_ADMIN \
  nicolaka/netshoot tcpdump -i eth0 -nn "tcp port 80 or tcp port 3306" -c 20 -w /tmp/incident.pcap >/dev/null
sleep 5
# base d'abord (SYN vers 3306), puis web (session HTTP complète)
docker exec incident-netshoot curl -s -o /dev/null --max-time 3 "http://$DB:3306/" 2>/dev/null || true
for i in 1 2 3; do
  docker exec incident-netshoot curl -s -o /dev/null "http://$WEB/" 2>/dev/null && break
  sleep 2
done
# tcpdump s'arrête seul à 10 paquets → on attend la fin du conteneur
for i in $(seq 1 15); do
  st=$(docker inspect -f '{{.State.Running}}' incident-netshoot 2>/dev/null || echo false)
  [ "$st" = "false" ] && break
  sleep 1
done
docker cp incident-netshoot:/tmp/incident.pcap /tmp/incident.pcap >/dev/null 2>&1 || true
out=$(tcpdump -r /tmp/incident.pcap -nn 2>/dev/null | head -12)
echo "$out"
echo "$out" | grep -qE "\.80:.*Flags \[S\]" && echo "✓ trafic HTTP vers le web observé" || { echo "✗ aucun trafic HTTP"; fail=1; }
echo "$out" | grep -qE "\.3306:.*Flags \[S\]" && echo "✓ tentative de connexion vers la base observée" || { echo "✗ aucun trafic vers la base"; fail=1; }
docker rm -f incident-netshoot >/dev/null 2>&1 || true

echo
echo "--- 5. Nettoyage ---"
docker rm -f "$WEB" "$DB" >/dev/null
docker network rm "$NET" >/dev/null
echo "✓ conteneurs et réseau supprimés"

echo
if [ "$fail" -eq 0 ]; then
  echo "✅ Ch08 Ex2 : VALIDÉ"
else
  echo "❌ Ch08 Ex2 : ÉCHEC"
  exit 1
fi
