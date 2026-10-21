#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  Chapitre  : 12 — Fondamentaux de la cryptographie
#  Exercice  : 1 (Débutant) — Chiffrer, hacher, signer avec OpenSSL
#  Version   : kali-rolling 2026.2 (openssl 3.x)
#  Exécution : bash scripts/04-crypto-secrets/12-kali_openssl_crypto.sh
#              (depuis lab/ ; nécessite `make up-pentest`)
#  Statut    : VALIDÉ (2026-08-11)
#
#  Adaptation Docker : le chiffrement interactif (mot de passe) est
#  scripté via `-pass pass:test` (clé de test uniquement).
#
#  ⚠️ CORRECTION MANUEL : `openssl enc -aes-256-gcm` ne fonctionne
#  PAS — la commande `enc` ne supporte pas les ciphers AEAD (GCM).
#  Vérifié OpenSSL 3.6.3 : « AEAD ciphers not supported ». On utilise
#  `-aes-256-cbc` (confidentialité) ; pour l'authentification, voir
#  la note du manuel (gpg/age/openssl cms).
# ─────────────────────────────────────────────────────────────
set -euo pipefail
cd "$(dirname "$0")/../.."   # → lab/

echo "== Ch12 Ex1 — Chiffrer, hacher, signer avec OpenSSL =="
fail=0

out=$(docker compose exec -T kali bash -c '
set -e
mkdir -p /tmp/crypto-test/test && cd /tmp/crypto-test/test

# 1. Fichier à protéger
echo "Donnée sensible de test" > message.txt

# 2. Empreinte
echo "--- empreinte ---"
sha256sum message.txt

# 3. Chiffrement AES-256-CBC (mot de passe de test)
#    NB : GCM (AEAD) n'\''est pas supporté par `openssl enc`.
openssl enc -aes-256-cbc -pbkdf2 -salt -pass pass:test -in message.txt -out message.bin
echo "--- fichier chiffré ---"
file message.bin

# 4. Paire de clés RSA (test uniquement)
openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:2048 -out cle_privee.pem 2>/dev/null
openssl rsa -in cle_privee.pem -pubout -out cle_publique.pem 2>/dev/null

# 5. Signature et vérification
openssl dgst -sha256 -sign cle_privee.pem -out message.sig message.txt
echo "--- vérification ---"
openssl dgst -sha256 -verify cle_publique.pem -signature message.sig message.txt
')
echo "$out"

echo
echo "--- Vérifications ---"
echo "$out" | grep -qE "^[0-9a-f]{64}  message.txt" && echo "✓ empreinte SHA-256 calculée" || { echo "✗ empreinte absente"; fail=1; }
echo "$out" | grep -q "data" && echo "✓ fichier chiffré (AES-256-CBC)" || { echo "✗ chiffrement absent"; fail=1; }
echo "$out" | grep -q "Verified OK" && echo "✓ signature vérifiée avec la clé publique" || { echo "✗ vérification de signature en échec"; fail=1; }

echo
if [ "$fail" -eq 0 ]; then
  echo "✅ Ch12 Ex1 : VALIDÉ"
else
  echo "❌ Ch12 Ex1 : ÉCHEC"
  exit 1
fi
