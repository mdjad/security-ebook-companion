#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  Chapitre  : 08 — Environnement de laboratoire
#  Exercice  : 1 (Débutant) — Créer votre premier laboratoire Kali + cible
#  Version   : Docker 29.6.2 + Compose v5.3.1 (Apple Silicon)
#  Exécution : bash scripts/02-socle-technique/08-host_topologie_lab.sh
#              (depuis lab/ ; nécessite `make up`)
#  Statut    : VALIDÉ (2026-08-11)
#
#  Adaptation Docker : le manuel construit le labo avec VirtualBox
#  (réseau host-only 10.77.0.0/24). Ici le labo EST ce script :
#  on valide la topologie réelle du lab (réseaux segmentés, edge,
#  isolation interne) — l'équivalent fonctionnel de l'exercice.
# ─────────────────────────────────────────────────────────────
set -euo pipefail
cd "$(dirname "$0")/../.."   # → lab/

echo "== Ch08 Ex1 — Validation de la topologie du laboratoire =="
fail=0

echo
echo "--- 1. Tous les services sont-ils sains ? ---"
out=$(docker compose ps --format '{{.Name}} {{.Status}}')
echo "$out"
echo "$out" | grep -q "healthy" || { echo "✗ aucun service healthy"; fail=1; }
n_unhealthy=$(echo "$out" | grep -c "unhealthy" || true)
[ "$n_unhealthy" -eq 0 ] || { echo "✗ $n_unhealthy service(s) unhealthy"; fail=1; }
echo "✓ services sains"

echo
echo "--- 2. Réseaux segmentés (seclab + seclab-internal) ---"
out=$(docker network ls --format '{{.Name}}' | grep seclab)
echo "$out"
echo "$out" | grep -q "seclab" && echo "✓ réseau seclab (accès Internet) présent" || { echo "✗ seclab absent"; fail=1; }
echo "$out" | grep -q "seclab-internal" && echo "✓ réseau seclab-internal (isolé) présent" || { echo "✗ seclab-internal absent"; fail=1; }

echo
echo "--- 3. Accès hôte via le service edge (127.0.0.1:18081-18084) ---"
for port in 18081 18082 18083 18084; do
  code=$(curl -s -o /dev/null -w '%{http_code}' --max-time 5 "http://127.0.0.1:$port/" || echo 000)
  echo "127.0.0.1:$port -> HTTP $code"
  [ "$code" != "000" ] || { echo "✗ port $port injoignable"; fail=1; }
done
echo "✓ passerelle edge opérationnelle"

echo
echo "--- 4. Isolation : les cibles internes n'ont AUCUN egress ---"
out=$(docker compose exec -T vuln-host bash -c "curl -s --max-time 5 http://1.1.1.1/ -o /dev/null -w '%{http_code}'" 2>&1 || true)
echo "egress cible -> ${out:-<échec attendu>}"
echo "$out" | grep -qE "000|Could not resolve|timed out|exit code" && echo "✓ aucune sortie Internet depuis les cibles" || { echo "✗ egress inattendu"; fail=1; }

echo
if [ "$fail" -eq 0 ]; then
  echo "✅ Ch08 Ex1 : VALIDÉ"
else
  echo "❌ Ch08 Ex1 : ÉCHEC"
  exit 1
fi
