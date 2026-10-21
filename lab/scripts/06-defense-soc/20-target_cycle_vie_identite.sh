#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  Chapitre  : 20 — Identités, accès, IAM et Active Directory
#  Exercice  : 1 (Débutant) — Cycle de vie d'une identité
#  Version   : vuln-host (debian:bookworm, comptes Linux)
#  Exécution : bash scripts/06-defense-soc/20-target_cycle_vie_identite.sh
#              (depuis lab/ ; nécessite `make up-pentest`)
#  Statut    : VALIDÉ (2026-08-12)
#
#  Adaptation Docker : le manuel propose « annuaire AD/Samba OU un
#  serveur Linux avec comptes » → on utilise les comptes Linux de
#  vuln-host (même leçon : groupes d'abord, droits minimaux,
#  verrouillage au départ, vérification de l'absence d'accès).
#  Le compte alice est supprimé en fin de script (idempotent).
# ─────────────────────────────────────────────────────────────
set -euo pipefail
cd "$(dirname "$0")/../.."   # → lab/

echo "== Ch20 Ex1 — Cycle de vie d'une identité =="
fail=0

out=$(docker compose exec -T vuln-host bash -c '
set -e
# Idempotence
userdel -r alice 2>/dev/null || true
groupdel appusers 2>/dev/null || true

echo "--- 1. Création (groupes d abord, utilisateur ensuite) ---"
groupadd -g 1010 appusers
useradd -m -g appusers -s /bin/bash alice
echo "alice:alice123" | chpasswd
id alice

echo "--- 2. Droits minimaux : pas de sudo pour alice ---"
sudo -l -U alice

echo "--- 3. Connexion de test ---"
su - alice -c "whoami && id"

echo "--- 4. Départ (leaver) : désactivation immédiate ---"
usermod -L alice
passwd -S alice

echo "--- 5. Vérification de l absence d accès ---"
sudo -l -U alice
lastlog | grep alice || echo "alice : jamais connectée (dernier accès absent)"

# Nettoyage (le compte de test ne reste pas sur la cible)
userdel -r alice 2>/dev/null || true
groupdel appusers 2>/dev/null || true
echo "--- nettoyage effectué ---"
')
echo "$out"

echo
echo "--- Vérifications ---"
echo "$out" | grep -q "uid=.*alice" && echo "✓ alice créée (groupe appusers)" || { echo "✗ alice non créée"; fail=1; }
echo "$out" | grep -qE "not allowed to run sudo|may not run sudo" && echo "✓ droits minimaux : pas de sudo pour alice" || { echo "✗ alice a des droits sudo"; fail=1; }
echo "$out" | grep -q "alice" && echo "✓ connexion de test (su - alice) fonctionne" || { echo "✗ connexion de test échouée"; fail=1; }
echo "$out" | grep -q "L" && echo "✓ compte verrouillé (usermod -L)" || { echo "✗ compte non verrouillé"; fail=1; }
echo "$out" | grep -q "nettoyage effectué" && echo "✓ nettoyage : compte de test supprimé" || { echo "✗ nettoyage absent"; fail=1; }

echo
if [ "$fail" -eq 0 ]; then
  echo "✅ Ch20 Ex1 : VALIDÉ"
else
  echo "❌ Ch20 Ex1 : ÉCHEC"
  exit 1
fi
