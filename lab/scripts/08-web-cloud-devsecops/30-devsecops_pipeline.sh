#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  Chapitre  : 30 — DevSecOps : sécuriser la chaîne CI/CD
#  Exercice  : 2 (Intermédiaire) — Construire un pipeline sécurisé et le durcir
#  Version   : devsecops-toolbox (act 0.2.89, checkov 3.3.10, terraform 1.9.8, cosign v2.4.3)
#  Exécution : bash scripts/08-web-cloud-devsecops/30-devsecops_pipeline.sh
#              (depuis lab/ ; nécessite `make up-devsecops`)
#  Statut    : VALIDÉ (2026-08-12)
#
#  Adaptation Docker : le workflow est listé avec `act --list` (pas
#  d'exécution complète, coûteuse) ; l'IaC est validé sur une copie
#  dans /tmp (le montage est en lecture seule) ; cosign signe sans
#  journal de transparence (mode laboratoire).
# ─────────────────────────────────────────────────────────────
set -euo pipefail
cd "$(dirname "$0")/../.."   # → lab/

echo "== Ch30 Ex2 — Pipeline sécurisé (workflow + IaC + signature) =="
fail=0

out=$(docker compose exec -T devsecops-toolbox bash -c '
set -e
cd /lab/apps/vuln-repo

# 1. Aucun secret en dur dans le workflow (grep négatif)
echo "--- secrets en dur dans .github/ ? ---"
if grep -RniE "(password|api[_-]?key|token) *[:=]" .github/; then
  echo "SECRET_TROUVE"
else
  echo "OK: pas de secret en dur"
fi

# 2. Workflow listé (act)
echo "--- act --list ---"
act --list 2>/dev/null | grep -E "securite-et-tests|Job ID" || echo "job introuvable"

# 3. IaC : politiques de sécurité (checkov)
echo "--- checkov (IaC) ---"
checkov -d infra --quiet --compact 2>/dev/null | grep -cE "FAILED" || echo "0"

# 4. IaC : syntaxe (terraform validate, sur copie /tmp)
rm -rf /tmp/infra-lab && cp -r /lab/apps/vuln-repo/infra /tmp/infra-lab
cd /tmp/infra-lab
terraform init -no-color >/dev/null 2>&1
terraform validate -no-color 2>&1 | head -1

# 5. Signature / vérification d artefact (cosign, sans tlog)
cd /tmp
export COSIGN_PASSWORD=""
rm -f cosign.key cosign.pub artefact.txt artefact.txt.sig
cosign generate-key-pair >/dev/null 2>&1
echo "artefact-lab" > artefact.txt
cosign sign-blob --key cosign.key --tlog-upload=false --output artefact.txt.sig artefact.txt >/dev/null 2>&1
cosign verify-blob --key cosign.pub --signature artefact.txt.sig --insecure-ignore-tlog artefact.txt 2>&1 | grep -E "Verified OK" || echo "vérification échouée"
')
echo "$out"

echo
echo "--- Vérifications ---"
echo "$out" | grep -q "OK: pas de secret en dur" && echo "✓ workflow : aucun secret en dur (grep négatif)" || { echo "✗ secret en dur dans le workflow"; fail=1; }
echo "$out" | grep -q "securite-et-tests" && echo "✓ act : job securite-et-tests listé" || { echo "✗ job non listé"; fail=1; }
echo "$out" | grep -qE "^[1-9][0-9]*$" && echo "✓ checkov : failles IaC détectées" || { echo "✗ checkov : aucune faille détectée"; fail=1; }
echo "$out" | grep -q "Success! The configuration is valid" && echo "✓ terraform validate : configuration valide" || { echo "✗ terraform validate en échec"; fail=1; }
echo "$out" | grep -q "Verified OK" && echo "✓ cosign : signature vérifiée" || { echo "✗ cosign : vérification en échec"; fail=1; }

echo
if [ "$fail" -eq 0 ]; then
  echo "✅ Ch30 Ex2 : VALIDÉ"
else
  echo "❌ Ch30 Ex2 : ÉCHEC"
  exit 1
fi
