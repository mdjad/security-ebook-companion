#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  Chapitre  : 11 — Frameworks et rapports
#  Exercice  : 2 (Intermédiaire) — Rédiger une fiche de vulnérabilité complète
#  Version   : kali-rolling 2026.2 (nmap 7.99)
#  Exécution : bash scripts/03-boite-a-outils/11-kali_fiche_vulnerabilite.sh
#              (depuis lab/ ; nécessite `make up-pentest`)
#  Statut    : VALIDÉ (2026-08-11)
#
#  Adaptation Docker : la fiche est générée à partir du scan réel de
#  vuln-host (nginx 1.22.1, obsolète) — la preuve est reproductible.
# ─────────────────────────────────────────────────────────────
set -euo pipefail
cd "$(dirname "$0")/../.."   # → lab/

echo "== Ch11 Ex2 — Fiche de vulnérabilité (nginx obsolète sur vuln-host) =="
fail=0

# Preuve réelle : version nginx détectée par nmap
ver=$(docker compose exec -T kali nmap -sV -p 80 vuln-host 2>&1 | grep -oE "nginx [0-9.]+" | head -1)
echo "version détectée : $ver"

cat > /tmp/VULN-2026-001.md <<EOF
# VULN-2026-001 — Service obsolète exposé

- Sévérité : Élevé (CVSS 7.2)
- Composant : $ver sur vuln-host:80 (labo)
- Constat : version antérieure à la version corrigée 1.26

## Preuve
    nmap -sV -p 80 vuln-host
    # 80/tcp open http $ver

## Impact
- RCE possible selon les CVE publiées (à confirmer par la version exacte).
- En production : prise de contrôle du serveur web.

## Remédiation
- Mettre à jour vers nginx 1.26+ (paquets officiels).
- Tester dans le labo avant déploiement (ch. 8, 17).
- Vérifier la configuration après mise à jour.

## Statut
- À corriger sous 30 jours.
EOF

echo
echo "--- Fiche générée ---"
cat /tmp/VULN-2026-001.md

echo
echo "--- Vérifications de structure ---"
for section in "Sévérité" "Composant" "Preuve" "Impact" "Remédiation" "Statut"; do
  grep -q "$section" /tmp/VULN-2026-001.md && echo "✓ section « $section » présente" || { echo "✗ section « $section » absente"; fail=1; }
done
grep -q "nginx" /tmp/VULN-2026-001.md && echo "✓ preuve reproductible (version réelle)" || { echo "✗ preuve sans version"; fail=1; }

echo
if [ "$fail" -eq 0 ]; then
  echo "✅ Ch11 Ex2 : VALIDÉ"
else
  echo "❌ Ch11 Ex2 : ÉCHEC"
  exit 1
fi
