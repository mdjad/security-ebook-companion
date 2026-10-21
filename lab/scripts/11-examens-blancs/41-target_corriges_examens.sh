#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  Chapitre  : 41 — Examen blanc n°2 (ch. 6-19)
#  Vérifie   : les commandes des corrigés (Ex2 ufw, Ex4 sauvegarde)
#  Version   : vuln-host (cible du lab)
#  Exécution : bash scripts/11-examens-blancs/41-target_corriges_examens.sh
#              (depuis lab/ ; nécessite `make up`)
#  Statut    : VALIDÉ (2026-08-12)
#
#  Corrigé Ex2 : `ufw default deny incoming` + `allow 22/443` + `enable`
#  + `status verbose` — testé puis **restauré** (disable + reset) pour ne
#  pas casser les exercices de pentest (Ch15/16).
#  Corrigé Ex4 : `tar -czf etc.tgz /etc` + `sha256sum` + `-c` (OK).
# ─────────────────────────────────────────────────────────────
set -euo pipefail
cd "$(dirname "$0")/../.."   # → lab/

echo "== Ch41 — Corrigés des exercices (Ex2 + Ex4) =="
fail=0

echo "--- Ex2 : durcir ufw (politique minimale) ---"
docker compose exec -T vuln-host bash -c '
  ufw default deny incoming 2>&1 | head -1
  ufw allow 22/tcp 2>&1 | head -1
  ufw allow 443/tcp 2>&1 | head -1
  echo y | ufw enable 2>&1 | head -1
  echo "--- status verbose ---"
  ufw status verbose 2>&1 | head -8
  echo "--- restauration (ne pas casser le pentest) ---"
  ufw --force disable 2>&1 | head -1
  ufw --force reset 2>&1 >/dev/null
  echo "status final : $(ufw status verbose 2>&1 | head -1)"
'

echo "--- Ex4 : sauvegarde vérifiée (tar + sha256sum) ---"
docker compose exec -T vuln-host bash -c '
  cd /tmp
  tar -czf etc.tgz /etc 2>/dev/null
  echo "archive : $(ls -la etc.tgz | awk "{print \$5}") octets"
  sha256sum etc.tgz > etc.sha256
  VERIF=$(sha256sum -c etc.sha256)
  echo "vérification : $VERIF"
  echo "$VERIF" | grep -q ": OK"
'

echo
echo "--- Vérifications ---"
docker compose exec -T vuln-host bash -c 'ufw status verbose 2>&1 | grep -q "Status: inactive"' && echo "✓ Ex2 : ufw restauré (inactive) — pentest préservé" || { echo "✗ ufw non restauré"; fail=1; }
docker compose exec -T vuln-host bash -c 'cd /tmp && sha256sum -c etc.sha256 2>/dev/null | grep -q ": OK"' && echo "✓ Ex4 : tar + sha256sum -c → OK" || { echo "✗ vérification tar échouée"; fail=1; }
docker compose exec -T vuln-host bash -c 'test -s /tmp/etc.tgz' && echo "✓ Ex4 : archive etc.tgz non vide" || { echo "✗ archive vide"; fail=1; }

echo
if [ "$fail" -eq 0 ]; then
  echo "✅ Ch41 corrigés : VALIDÉ"
else
  echo "❌ Ch41 corrigés : ÉCHEC"
  exit 1
fi
