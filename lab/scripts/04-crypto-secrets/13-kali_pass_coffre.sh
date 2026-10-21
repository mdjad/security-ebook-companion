#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  Chapitre  : 13 — Secrets, données et sauvegardes
#  Exercice  : 1 (Débutant) — Coffre de secrets local avec pass
#  Version   : kali-rolling 2026.2 (pass 1.7.4, gpg 2.4.9)
#  Exécution : bash scripts/04-crypto-secrets/13-kali_pass_coffre.sh
#              (depuis lab/ ; nécessite `make up-pentest`)
#  Statut    : VALIDÉ (2026-08-11)
#
#  Adaptation Docker : la clé GPG est générée en mode batch
#  (sans phrase de passe, clé de test uniquement).
# ─────────────────────────────────────────────────────────────
set -euo pipefail
cd "$(dirname "$0")/../.."   # → lab/

echo "== Ch13 Ex1 — Coffre de secrets local avec pass =="
fail=0

out=$(docker compose exec -T kali bash -c '
set -e
export GNUPGHOME=/tmp/gnupg-lab
mkdir -p "$GNUPGHOME" && chmod 700 "$GNUPGHOME"

# 1. Clé GPG (batch, test uniquement)
gpg --batch --gen-key <<EOF 2>/dev/null
%no-protection
Key-Type: RSA
Key-Length: 2048
Name-Real: Lab Test
Name-Email: lab@test.local
Expire-Date: 0
EOF

# 2. Initialiser pass
pass init "Lab Test <lab@test.local>" >/dev/null

# 3. Insérer des secrets
echo "email@entreprise.fr" | pass insert -m entreprise/email >/dev/null
echo "vpn-secret-123" | pass insert -m entreprise/vpn >/dev/null

# 4. Lire (déchiffre à la volée)
echo "--- lecture ---"
pass show entreprise/email

# 5. Vérifier le chiffrement au repos
echo "--- fichier au repos ---"
file ~/.password-store/entreprise/email.gpg
')
echo "$out"

echo
echo "--- Vérifications ---"
echo "$out" | grep -q "email@entreprise.fr" && echo "✓ secret lu (déchiffré à la volée)" || { echo "✗ lecture du secret en échec"; fail=1; }
echo "$out" | grep -qE "PGP|encrypted" && echo "✓ fichier chiffré au repos (GPG)" || { echo "✗ fichier non chiffré"; fail=1; }

echo
if [ "$fail" -eq 0 ]; then
  echo "✅ Ch13 Ex1 : VALIDÉ"
else
  echo "❌ Ch13 Ex1 : ÉCHEC"
  exit 1
fi
