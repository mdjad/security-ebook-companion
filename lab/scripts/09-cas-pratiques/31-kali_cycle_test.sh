#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  Chapitre  : 31 — Cas pratique : construire un laboratoire de pentest
#  Exercice  : 2 (Intermédiaire) — Réaliser un cycle de test sur vos cibles
#  Version   : kali → vuln-host (lab Docker)
#  Exécution : bash scripts/09-cas-pratiques/31-kali_cycle_test.sh
#              (depuis lab/ ; nécessite `make up-pentest`)
#  Statut    : VALIDÉ (2026-08-12)
#
#  Adaptation Docker : le manuel prend un snapshot VirtualBox puis le
#  restaure. Le lab Docker utilise vuln-host (nginx 1.22.1 volontaire,
#  cf. Ch15) : cartographie → constat documenté (preuve horodatée) →
#  restauration = redémarrage du conteneur (état propre, reproductible).
# ─────────────────────────────────────────────────────────────
set -euo pipefail
cd "$(dirname "$0")/../.."   # → lab/

echo "== Ch31 Ex2 — Cycle de test (kali → vuln-host) =="
fail=0

echo "--- 1. Cartographie (périmètre autorisé) ---"
SCAN=$(docker compose exec -T kali nmap -sV -p 21,22,80,3306 vuln-host 2>/dev/null | grep -E "^[0-9]+/tcp" || true)
echo "$SCAN"
PORT_HTTP=$(echo "$SCAN" | awk '$1 ~ /^80\// {print $1, $2, $3, $4}' | head -1)
echo "port 80 : $PORT_HTTP"

echo "--- 2. Constat (fiche VULN-001) ---"
cat > /tmp/constat-VULN-001.md <<'EOF'
# VULN-001 — Service obsolète (nginx 1.22.1)

- Cible : vuln-host (10.77.0.x dans le manuel ; nom de conteneur dans le lab)
- Service : HTTP (80/tcp), nginx 1.22.1
- Impact : versions 1.22.0-1.22.1 exposées à des CVE connues (moyen/élevé)
- Preuve : sortie nmap -sV ci-dessous (horodatée)
- Remédiation : mettre à niveau nginx (>= 1.22.2 / 1.24), scan Trivy (ch. 29)
- État : À CORRIGER
EOF
cat /tmp/constat-VULN-001.md

echo "--- 3. Preuve horodatée ---"
docker compose exec -T vuln-host date -u +%Y-%m-%dT%H:%M:%SZ > /tmp/preuve-date.txt
cat /tmp/preuve-date.txt

echo "--- 4. Restauration (état propre du conteneur) ---"
docker compose restart vuln-host >/dev/null 2>&1
echo "vuln-host redémarré (équivalent snapshot propre)"
sleep 3
docker compose exec -T vuln-host ss -tlnp | grep -q ":80" && echo "service HTTP de nouveau actif" || { echo "✗ HTTP non relancé après redémarrage"; fail=1; }

echo
echo "--- Vérifications ---"
echo "$SCAN" | grep -q "80/tcp" && echo "✓ cartographie : port 80 identifié" || { echo "✗ port 80 absent"; fail=1; }
echo "$SCAN" | grep -qi "nginx 1.22.1" && echo "✓ version nginx 1.22.1 identifiée (constat VULN-001)" || { echo "✗ version nginx non identifiée"; fail=1; }
grep -q "nginx 1.22.1" /tmp/constat-VULN-001.md && echo "✓ constat documenté (impact + remédiation)" || { echo "✗ constat incomplet"; fail=1; }
grep -q "^[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}" /tmp/preuve-date.txt && echo "✓ preuve horodatée UTC" || { echo "✗ preuve non horodatée"; fail=1; }

echo
if [ "$fail" -eq 0 ]; then
  echo "✅ Ch31 Ex2 : VALIDÉ"
else
  echo "❌ Ch31 Ex2 : ÉCHEC"
  exit 1
fi
