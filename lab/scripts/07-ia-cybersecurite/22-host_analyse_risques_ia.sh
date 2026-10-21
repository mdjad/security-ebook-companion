#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  Chapitre  : 22 — Comprendre l'IA en cybersécurité
#  Exercice  : 2 (Intermédiaire) — Analyser les risques d'un système d'IA
#  Version   : validation par modèle de document
#  Exécution : bash scripts/07-ia-cybersecurite/22-host_analyse_risques_ia.sh
#              (depuis lab/ ; aucun service requis)
#  Statut    : VALIDÉ (2026-08-12)
#
#  Adaptation Docker : l'exercice est un document. Le script génère
#  l'analyse de risques en 5 dimensions (données, traitement,
#  capacités, supervision, réglementation) et vérifie que chaque
#  dimension contient ≥ 2 risques + une recommandation actionnable.
# ─────────────────────────────────────────────────────────────
set -euo pipefail
cd "$(dirname "$0")/../.."   # → lab/

echo "== Ch22 Ex2 — Analyse des risques d'un système d'IA (document) =="
fail=0

cat > /tmp/analyse-risques-ia.md <<'EOF'
# Analyse des risques — assistant IA documentation technique (fictif)

## 1. Données utilisées
- Risques : exfiltration de secrets.
- Risques : fuite de connaissances propriétaires.
- Recommandation : filtrer les secrets (scanner avant envoi), classifier les documents.

## 2. Traitement (externe / interne)
- Risques : fuite vers le fournisseur.
- Risques : réutilisation des données.
- Recommandation : évaluer un modèle interne pour les données sensibles, interdire le code propriétaire.

## 3. Capacités du modèle (lecture seule / actions)
- Risques : un agent avec accès pourrait exécuter des actions non autorisées.
- Risques : escalade de privilèges via un outil connecté.
- Recommandation : commencer en lecture seule, autorisations minimales.

## 4. Supervision humaine
- Risques : hallucination conduisant à une mauvaise décision technique.
- Risques : absence de traçabilité des décisions.
- Recommandation : relecture humaine pour les réponses à enjeu, journalisation.

## 5. Exigences réglementaires (RGPD, AI Act)
- Risques : non-conformité RGPD (données personnelles).
- Risques : AI Act (usage à haut risque).
- Recommandation : vérifier la classification, réaliser une AIPD si nécessaire.
EOF

echo "--- Document généré ---"
cat /tmp/analyse-risques-ia.md

echo
echo "--- Vérifications ---"
for dim in "1. Données" "2. Traitement" "3. Capacités" "4. Supervision" "5. Exigences"; do
  grep -q "^## $dim" /tmp/analyse-risques-ia.md && echo "✓ dimension « $dim » présente" || { echo "✗ dimension « $dim » absente"; fail=1; }
done
for dim in "1. Données" "2. Traitement" "3. Capacités" "4. Supervision" "5. Exigences"; do
  # Compte les lignes « - Risques » de la section courante (le motif de fin
  # « ^## » ne doit pas matcher l'en-tête de la section elle-même).
  n=$(awk -v s="^## $dim" '$0 ~ s {f=1; next} /^## / {f=0} f && /^- Risques/ {c++} END {print c+0}' /tmp/analyse-risques-ia.md)
  [ "$n" -ge 2 ] && echo "✓ « $dim » : $n risques identifiés" || { echo "✗ « $dim » : $n risques (< 2)"; fail=1; }
done
grep -q "Recommandation" /tmp/analyse-risques-ia.md && echo "✓ recommandations actionnables présentes" || { echo "✗ recommandations absentes"; fail=1; }
grep -q "AIPD" /tmp/analyse-risques-ia.md && echo "✓ AIPD mentionnée (dimension réglementaire)" || { echo "✗ AIPD absente"; fail=1; }

echo
if [ "$fail" -eq 0 ]; then
  echo "✅ Ch22 Ex2 : VALIDÉ"
else
  echo "❌ Ch22 Ex2 : ÉCHEC"
  exit 1
fi
