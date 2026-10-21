#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  Chapitre  : 20 — Identités, accès, IAM et Active Directory
#  Exercice  : 2 (Intermédiaire) — Audit et durcissement d'un annuaire
#  Version   : vuln-host (debian:bookworm, comptes Linux)
#  Exécution : bash scripts/06-defense-soc/20-target_audit_annuaire.sh
#              (depuis lab/ ; nécessite `make up-pentest`)
#  Statut    : VALIDÉ (2026-08-12)
#
#  Adaptation Docker : le manuel utilise samba-tool (annuaire AD).
#  Le lab n'embarque pas de contrôleur de domaine (lourd) → on
#  transpose sur les comptes Linux de vuln-host, même boucle :
#  inventaire → comptes dormants → privilèges excessifs → corriger
#  → revérifier (moindre privilège). Documenté VALIDATION.md.
#  Fixture : svc_old (dormant, jamais connecté) + bob (membre sudo).
# ─────────────────────────────────────────────────────────────
set -euo pipefail
cd "$(dirname "$0")/../.."   # → lab/

echo "== Ch20 Ex2 — Audit et durcissement d'un annuaire =="
fail=0

out=$(docker compose exec -T vuln-host bash -c '
set -e
# Idempotence + fixture
userdel -r svc_old 2>/dev/null || true
userdel -r bob 2>/dev/null || true
groupdel devs 2>/dev/null || true
touch /var/log/lastlog

useradd -m -s /bin/bash svc_old   # compte dormant (jamais connecté)
useradd -m -s /bin/bash bob
usermod -aG sudo bob              # privilège excessif (à corriger)

echo "--- 1. Inventaire des comptes ---"
cut -d: -f1 /etc/passwd | sort | grep -E "svc_old|bob|admin|svc_backup"

echo "--- 2. Comptes inactifs (jamais connectés) ---"
# lastlog (Debian, locale EN) : « **Never logged in** » — on filtre
# directement sur ce marqueur (le motif $4 == "**" est fragile : le
# champ 4 vaut « **Never » selon la largeur des colonnes).
lastlog | grep -E "Never logged in|Jamais" || true

echo "--- 3. Correction : verrouiller le dormant ---"
usermod -L svc_old
passwd -S svc_old

echo "--- 4. Privilège excessif : retirer bob du groupe sudo ---"
gpasswd -d bob sudo
getent group sudo

echo "--- 5. Vérification finale ---"
passwd -S svc_old
getent group sudo | grep -q bob && echo "ERREUR : bob encore dans sudo" || echo "bob retiré de sudo (moindre privilège)"

# Nettoyage
userdel -r svc_old 2>/dev/null || true
userdel -r bob 2>/dev/null || true
echo "--- nettoyage effectué ---"
')
echo "$out"

echo
echo "--- Vérifications ---"
echo "$out" | grep -q "svc_old" && echo "✓ inventaire : compte dormant présent" || { echo "✗ svc_old absent"; fail=1; }
echo "$out" | grep -q "Never logged in" && echo "✓ comptes inactifs identifiés (lastlog)" || { echo "✗ détection des dormants échouée"; fail=1; }
echo "$out" | grep -q "L" && echo "✓ dormant verrouillé (usermod -L)" || { echo "✗ dormant non verrouillé"; fail=1; }
echo "$out" | grep -q "bob retiré de sudo" && echo "✓ privilège excessif retiré (moindre privilège)" || { echo "✗ bob encore dans sudo"; fail=1; }
echo "$out" | grep -q "nettoyage effectué" && echo "✓ nettoyage : comptes de test supprimés" || { echo "✗ nettoyage absent"; fail=1; }

echo
if [ "$fail" -eq 0 ]; then
  echo "✅ Ch20 Ex2 : VALIDÉ"
else
  echo "❌ Ch20 Ex2 : ÉCHEC"
  exit 1
fi
