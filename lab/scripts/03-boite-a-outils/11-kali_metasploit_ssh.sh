#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  Chapitre  : 11 — Frameworks et rapports
#  Exercice  : 1 (Débutant) — Explorer Metasploit dans votre laboratoire
#  Version   : kali-rolling 2026.2 (metasploit-framework 6.5.0)
#  Exécution : bash scripts/03-boite-a-outils/11-kali_metasploit_ssh.sh
#              (depuis lab/ ; nécessite `make up-pentest`)
#  Statut    : VALIDÉ (2026-08-11)
#
#  Adaptation Docker : msfconsole est scripté via `-q -x` (premier
#  lancement lent ~10-30 s). La cible est vuln-host (nom de conteneur).
# ─────────────────────────────────────────────────────────────
set -euo pipefail
cd "$(dirname "$0")/../.."   # → lab/

echo "== Ch11 Ex1 — Cycle Metasploit : search / use / info / set / run =="
fail=0

out=$(docker compose exec -T kali bash -c 'msfconsole -q -x "search type:auxiliary name:ssh; use auxiliary/scanner/ssh/ssh_version; info; set RHOSTS vuln-host; run; exit -y" 2>&1')
echo "$out" | grep -E "auxiliary/scanner/ssh/ssh_version|SSH server version|RHOSTS|Name:" | head -12

echo
echo "--- Vérifications ---"
echo "$out" | grep -q "auxiliary/scanner/ssh/ssh_version" && echo "✓ module trouvé (search)" || { echo "✗ search n'a rien trouvé"; fail=1; }
echo "$out" | grep -qE "Module: auxiliary/scanner/ssh/ssh_version|Name:.*ssh_version" && echo "✓ fiche info lue" || { echo "✗ info non affichée"; fail=1; }
echo "$out" | grep -q "SSH server version: SSH-2.0-OpenSSH" && echo "✓ bannière SSH lue (run)" || { echo "✗ run n'a pas lu la bannière"; fail=1; }

echo
if [ "$fail" -eq 0 ]; then
  echo "✅ Ch11 Ex1 : VALIDÉ"
else
  echo "❌ Ch11 Ex1 : ÉCHEC"
  exit 1
fi
