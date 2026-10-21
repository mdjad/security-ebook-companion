#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  Chapitre  : 32 — Cas pratique : test d'intrusion web
#  Exercice  : 3 (Confirmé) — Produire le rapport final et planifier le re-test
#  Version   : document (rapport livrable)
#  Exécution : bash scripts/09-cas-pratiques/32-host_rapport_test.sh
#              (depuis lab/)
#  Statut    : VALIDÉ (2026-08-12)
#
#  Adaptation Docker : le rapport reprend la structure du chapitre 16
#  (synthèse exécutive, périmètre, constats, priorités, feuille de
#  route) appliquée au test de vuln-api (Ch32 Ex2). Les constats
#  VULN-001 (BOLA) et VULN-002 (en-têtes) sont ceux du lab.
# ─────────────────────────────────────────────────────────────
set -euo pipefail
cd "$(dirname "$0")/../.."   # → lab/

echo "== Ch32 Ex3 — Rapport final de test (web) =="
fail=0

DOC=/tmp/rapport-test-web.md
cat > "$DOC" <<'EOF'
# Rapport de test — application web (labo)

## 1. Synthèse exécutive
- 2 constats : 1 élevé (contrôle d'accès), 1 moyen (en-têtes manquants).
- Aucune dégradation ; environnement labo.
- Priorités : corriger l'accès aux objets (15 j), ajouter les en-têtes (30 j).

## 2. Périmètre et règles d'engagement
- Cible : vuln-api (Ch27-28), réseau interne seclab-internal.
- Portée : endpoints /api/* et /v1/* ; comptes de test A/B.
- Dates, contraintes, contacts : cf. document des règles d'engagement.

## 3. Constats
| ID | Titre | Sévérité | Preuve | Remédiation |
|---|---|---|---|---|
| VULN-001 | BOLA / IDOR | Élevé | HTTP 200 objet de B (jeton A) | vérification côté serveur |
| VULN-002 | en-têtes absents | Moyen | curl -I | configurer HSTS/CSP |

## 4. Priorités (risque métier)
1. VULN-001 : accès aux données d'autres comptes -> 15 j
2. VULN-002 : posture navigateur -> 30 j

## 5. Feuille de route et re-test
- Correction VULN-001 : contrôle d'appartenance (ch. 27) — responsable : dev.
- Correction VULN-002 : en-têtes via edge (SECURITY_HEADERS=on) — responsable : infra.
- Re-test : après correction, rejouer le cycle (Ch32 Ex2) et vérifier 403.
EOF

echo "--- Rapport généré ---"
cat "$DOC"

echo
echo "--- Vérifications ---"
grep -q "^## 1. Synthèse exécutive" "$DOC" && echo "✓ synthèse exécutive" || { echo "✗ synthèse absente"; fail=1; }
grep -q "^## 2. Périmètre" "$DOC" && echo "✓ périmètre" || { echo "✗ périmètre absent"; fail=1; }
grep -q "^## 3. Constats" "$DOC" && echo "✓ constats" || { echo "✗ constats absents"; fail=1; }
grep -q "VULN-001" "$DOC" && echo "✓ constat VULN-001 (BOLA)" || { echo "✗ VULN-001 absent"; fail=1; }
grep -q "^## 4. Priorités" "$DOC" && echo "✓ priorités (risque métier)" || { echo "✗ priorités absentes"; fail=1; }
grep -q "^## 5. Feuille de route" "$DOC" && echo "✓ feuille de route + re-test" || { echo "✗ feuille de route absente"; fail=1; }
grep -q "re-test" "$DOC" && echo "✓ re-test planifié" || { echo "✗ re-test absent"; fail=1; }

echo
if [ "$fail" -eq 0 ]; then
  echo "✅ Ch32 Ex3 : VALIDÉ"
else
  echo "❌ Ch32 Ex3 : ÉCHEC"
  exit 1
fi
