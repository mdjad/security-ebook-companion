#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  Chapitre  : 10 — Outils de reconnaissance et d'analyse
#  Exercice  : 2 (Intermédiaire) — Analyse d'une application web locale avec ZAP
#  Version   : zaproxy/zap-stable 2.17.0 (daemon, API REST)
#  Exécution : bash scripts/03-boite-a-outils/10-zap_dvwa_scan.sh
#              (depuis lab/ ; nécessite `make up-web`)
#  Statut    : VALIDÉ (2026-08-11)
#
#  Adaptation Docker : le manuel lance `zap.sh -quickurl` (GUI).
#  Ici ZAP tourne en daemon → spider + scan passif via l'API REST,
#  puis liste des alertes. DVWA est joignable par nom (`dvwa:80`).
#  NB : le scan actif complet de DVWA dure ~10 min ; le spider +
#  scan passif suffit à produire une liste d'alertes exploitable
#  (équivalent fonctionnel de `-quickurl`).
# ─────────────────────────────────────────────────────────────
set -euo pipefail
cd "$(dirname "$0")/../.."   # → lab/

API="http://127.0.0.1:8080"
KEY="seclab-zap-key"
TARGET="http://dvwa/"

zap() { docker compose exec -T zap curl -s --max-time 10 "$API$1"; }

echo "== Ch10 Ex2 — Analyse DVWA avec OWASP ZAP =="
fail=0

echo
echo "--- 1. API ZAP disponible ---"
v=$(zap "/JSON/core/view/version?apikey=$KEY")
echo "ZAP version : $v"
echo "$v" | grep -q '"version"' || { echo "✗ API ZAP injoignable"; fail=1; }

echo
echo "--- 2. Spider (exploration automatique) ---"
sid=$(zap "/JSON/spider/action/scan?url=$TARGET&apikey=$KEY" | sed -E 's/.*"scan":"?([0-9]+)"?.*/\1/')
echo "spider id : $sid"
[ -n "$sid" ] && [ "$sid" != "$(echo "$sid" | tr -d '0-9')" ] || { echo "✗ spider non démarré"; fail=1; }
for i in $(seq 1 30); do
  st=$(zap "/JSON/spider/view/status?scanId=$sid&apikey=$KEY" | sed -E 's/.*"status":"?([0-9]+)"?.*/\1/')
  [ "$st" = "100" ] && break
  sleep 3
done
echo "spider terminé (statut $st)"
[ "$st" = "100" ] || { echo "✗ spider incomplet"; fail=1; }

echo
echo "--- 3. Alertes (scan passif pendant l'exploration) ---"
alerts=$(zap "/JSON/core/view/alerts?baseurl=$TARGET&apikey=$KEY")
n=$(echo "$alerts" | grep -o '"alert"' | wc -l | tr -d ' ')
echo "alertes détectées : $n"
echo "$alerts" | grep -o '"risk":"[^"]*"' | sort | uniq -c | sort -rn | head -6
[ "$n" -gt 0 ] && echo "✓ alertes détectées (à vérifier manuellement)" || { echo "✗ aucune alerte"; fail=1; }

echo
echo "--- 4. Vérification manuelle d'une alerte (exemple) ---"
sample=$(echo "$alerts" | grep -o '"alert":"[^"]*"' | head -1)
echo "alerte à vérifier : $sample"
[ -n "$sample" ] && echo "✓ alerte identifiée pour vérification manuelle" || { echo "✗ aucune alerte à vérifier"; fail=1; }

echo
if [ "$fail" -eq 0 ]; then
  echo "✅ Ch10 Ex2 : VALIDÉ"
else
  echo "❌ Ch10 Ex2 : ÉCHEC"
  exit 1
fi
