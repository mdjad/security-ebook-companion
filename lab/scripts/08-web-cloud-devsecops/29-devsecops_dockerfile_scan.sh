#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  Chapitre  : 29 — Sécurité cloud et conteneurs
#  Exercice  : 2 (Intermédiaire) — Sécuriser un Dockerfile et scanner une image
#  Version   : devsecops-toolbox (hadolint 2.12.0, trivy 0.73.0, syft 1.51.0)
#  Exécution : bash scripts/08-web-cloud-devsecops/29-devsecops_dockerfile_scan.sh
#              (depuis lab/ ; nécessite `make up-devsecops`)
#  Statut    : VALIDÉ (2026-08-12)
#
#  Adaptation Docker : l'image `sample-app:lab` est construite via le
#  socket docker (le conteneur devsecops y a accès). Le Dockerfile
#  est déjà durci (base maintenue, non root, pas de secrets) ; le
#  constat restant est DL3008 (épingler les versions apt).
# ─────────────────────────────────────────────────────────────
set -euo pipefail
cd "$(dirname "$0")/../.."   # → lab/

echo "== Ch29 Ex2 — Dockerfile sécurisé + scan d'image =="
fail=0

out=$(docker compose exec -T devsecops-toolbox bash -c '
set -e
# 1. Image présente (build si besoin, via docker.sock)
docker image inspect sample-app:lab >/dev/null 2>&1 || docker build -q -t sample-app:lab /lab/apps/sample-app

# 2. Lint du Dockerfile (hadolint)
echo "--- hadolint ---"
hadolint /lab/apps/sample-app/Dockerfile || true

# 3. Scan de vulnérabilités (trivy)
echo "--- trivy (HIGH/CRITICAL) ---"
trivy image --severity HIGH,CRITICAL --no-progress sample-app:lab 2>/dev/null | grep -cE "CVE-" | sed "s/^/CVE count: /"

# 4. SBOM (syft)
echo "--- syft (SBOM CycloneDX) ---"
syft packages sample-app:lab -o cyclonedx-json 2>/dev/null | head -c 60
echo

# 5. Non-root
echo "--- utilisateur du conteneur ---"
docker run --rm sample-app:lab whoami
')
echo "$out"

echo
echo "--- Vérifications ---"
echo "$out" | grep -q "DL3008" && echo "✓ hadolint : DL3008 signalé (épingler les versions apt)" || { echo "✗ DL3008 non signalé"; fail=1; }
echo "$out" | grep -qE "CVE count: [1-9]" && echo "✓ trivy : vulnérabilités HIGH/CRITICAL remontées" || { echo "✗ aucune vulnérabilité remontée"; fail=1; }
echo "$out" | grep -q "cyclonedx" && echo "✓ syft : SBOM CycloneDX généré" || { echo "✗ SBOM non généré"; fail=1; }
echo "$out" | grep -qE "^app$" && echo "✓ conteneur non root (utilisateur app)" || { echo "✗ conteneur root"; fail=1; }

echo
if [ "$fail" -eq 0 ]; then
  echo "✅ Ch29 Ex2 : VALIDÉ"
else
  echo "❌ Ch29 Ex2 : ÉCHEC"
  exit 1
fi
