#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  Chapitre  : 24 — La défense augmentée par l'IA
#  Exercice  : 3 (Confirmé) — Mesurer un faux positif d'IA
#  Version   : awk + python3 sur journal fictif (labo)
#  Exécution : bash scripts/07-ia-cybersecurite/24-host_mesure_faux_positifs.sh
#              (depuis lab/ ; aucun service requis)
#  Statut    : VALIDÉ (2026-08-12)
#
#  Adaptation Docker : l'exercice est une mesure sur journal fictif.
#  Le script génère 20 alertes (10 vraies, 10 fausses), l'assistant
#  en signale 12 (8 correctes, 4 fausses), 2 vraies manquées → on
#  calcule TP/FP/FN puis précision, rappel et F1. Conclusion :
#  supervision obligatoire (le « supervisé » du chapitre).
# ─────────────────────────────────────────────────────────────
set -euo pipefail
cd "$(dirname "$0")/../.."   # → lab/

echo "== Ch24 Ex3 — Mesurer un faux positif d'IA =="
fail=0

# 1. Journal fictif : 20 alertes (vrai/faux × signalee/non_signalee)
cat > /tmp/journal-assistant.txt <<'EOF'
alerte:09:00 ip1 vrai signalee
alerte:09:01 ip2 vrai signalee
alerte:09:02 ip3 vrai signalee
alerte:09:03 ip4 vrai signalee
alerte:09:04 ip5 vrai signalee
alerte:09:05 ip6 vrai signalee
alerte:09:06 ip7 vrai signalee
alerte:09:07 ip8 vrai signalee
alerte:09:08 ip9 vrai non_signalee
alerte:09:09 ip10 vrai non_signalee
alerte:09:10 ip11 faux signalee
alerte:09:11 ip12 faux signalee
alerte:09:12 ip13 faux signalee
alerte:09:13 ip14 faux signalee
alerte:09:14 ip15 faux non_signalee
alerte:09:15 ip16 faux non_signalee
alerte:09:16 ip17 faux non_signalee
alerte:09:17 ip18 faux non_signalee
alerte:09:18 ip19 faux non_signalee
alerte:09:19 ip20 faux non_signalee
EOF

echo "--- 1. Journal fictif : $(wc -l < /tmp/journal-assistant.txt) alertes ---"

# 2. Compter TP / FP / FN (règles documentées)
TP=$(awk '$3=="vrai" && $4=="signalee" {c++} END{print c+0}' /tmp/journal-assistant.txt)
FP=$(awk '$3=="faux" && $4=="signalee" {c++} END{print c+0}' /tmp/journal-assistant.txt)
FN=$(awk '$3=="vrai" && $4=="non_signalee" {c++} END{print c+0}' /tmp/journal-assistant.txt)
echo "--- 2. Comptage ---"
echo "vrais positifs (TP) : $TP"
echo "faux positifs (FP)  : $FP"
echo "manquées (FN)       : $FN"

# 3. Précision / rappel / F1
METRICS=$(python3 - "$TP" "$FP" "$FN" <<'PYEOF'
import sys
tp, fp, fn = int(sys.argv[1]), int(sys.argv[2]), int(sys.argv[3])
p = tp / (tp + fp) if (tp + fp) else 0
r = tp / (tp + fn) if (tp + fn) else 0
f1 = 2 * p * r / (p + r) if (p + r) else 0
print(f"précision : {p:.0%} ; rappel : {r:.0%} ; F1 : {f1:.2f}")
PYEOF
)
echo "--- 3. Métriques ---"
echo "$METRICS"

echo "--- 4. Conclusion ---"
# NB : heredoc écrit dans un fichier puis relu — un apostrophe dans un
# heredoc imbriqué dans $(...) casse le parseur bash (EOF inattendu).
cat > /tmp/conclusion-faux-positifs.txt <<'EOF'
L'assistant réduit le bruit mais manque des signaux et produit des faux.
→ supervision obligatoire ; seuils ajustés ; re-test mensuel.
EOF
CONCLUSION=$(cat /tmp/conclusion-faux-positifs.txt)
echo "$CONCLUSION"

echo
echo "--- Vérifications ---"
[ "$TP" -eq 8 ] && echo "✓ TP = 8 (vraies alertes signalées)" || { echo "✗ TP = $TP (attendu 8)"; fail=1; }
[ "$FP" -eq 4 ] && echo "✓ FP = 4 (faux positifs)" || { echo "✗ FP = $FP (attendu 4)"; fail=1; }
[ "$FN" -eq 2 ] && echo "✓ FN = 2 (alertes manquées)" || { echo "✗ FN = $FN (attendu 2)"; fail=1; }
echo "$METRICS" | grep -q "précision : 67%" && echo "✓ précision 67 % (8/12)" || { echo "✗ précision inattendue : $METRICS"; fail=1; }
echo "$METRICS" | grep -q "rappel : 80%" && echo "✓ rappel 80 % (8/10)" || { echo "✗ rappel inattendu"; fail=1; }
echo "$CONCLUSION" | grep -q "supervision obligatoire" && echo "✓ conclusion : supervision obligatoire" || { echo "✗ conclusion absente"; fail=1; }

echo
if [ "$fail" -eq 0 ]; then
  echo "✅ Ch24 Ex3 : VALIDÉ"
else
  echo "❌ Ch24 Ex3 : ÉCHEC"
  exit 1
fi
