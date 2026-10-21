#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  Chapitre  : 31 — Cas pratique : construire un laboratoire de pentest
#  Exercice  : 1 (Débutant) — Installer et documenter un laboratoire minimal
#  Version   : lab Docker (équivalent fonctionnel de VirtualBox)
#  Exécution : bash scripts/09-cas-pratiques/31-host_fiche_laboratoire.sh
#              (depuis lab/ ; nécessite `make up-pentest`)
#  Statut    : VALIDÉ (2026-08-12)
#
#  Adaptation Docker : le manuel crée un réseau host-only VirtualBox.
#  Le lab Docker fournit l'équivalent : réseau interne isolé (aucun
#  egress), cibles sans ports publiés, edge sur 127.0.0.1. Le script
#  vérifie l'état (healthy), l'isolation (pas de route par défaut sur
#  les cibles) et génère la fiche du laboratoire documentée.
# ─────────────────────────────────────────────────────────────
set -euo pipefail
cd "$(dirname "$0")/../.."   # → lab/

echo "== Ch31 Ex1 — Fiche du laboratoire (Docker) =="
fail=0

# 1. Vérifier que toutes les cibles sont healthy
echo "--- 1. État des conteneurs ---"
docker compose ps --format '{{.Name}} {{.Health}}' | grep -E "dvwa|juice-shop|vuln-host|vuln-api|web-lab|edge" || true

# 2. Isolation : aucune route par défaut sur les cibles (pas d'egress)
echo "--- 2. Isolation réseau (cible = vuln-host) ---"
ROUTE=$(docker compose exec -T vuln-host ip route 2>/dev/null || true)
echo "routes : $(echo "$ROUTE" | tr '\n' ' ')"
[ -z "$ROUTE" ] || echo "note : route présente = $ROUTE"

# 3. Générer la fiche du laboratoire
FICHE=/tmp/fiche-laboratoire.md
cat > "$FICHE" <<'EOF'
# Fiche du laboratoire (Docker)

## Réseaux
- `seclab` : bridge avec accès Internet (attaquant, outils, edge).
- `seclab-internal` : bridge internal (aucun egress) — cibles.

## Machines
- Poste d'attaque : kali (pentest-toolbox) sur les 2 réseaux (pivot).
- Cibles (réseau interne, aucun port publié) :
  | Cible | Rôle |
  |---|---|
  | vuln-host | hôte vulnérable (SSH/FTP/HTTP/MySQL, SUID) |
  | vuln-api | API vulnérable (Ch27-28) |
  | dvwa | application web vulnérable |
  | juice-shop | application web/API moderne vulnérable |
  | web-lab | serveur web de test (en-têtes, Ch27) |
- Passerelle : edge (nginx) sur 127.0.0.1:18081-18084.
- IDS : suricata (réseau interne).

## Règles
- Aucun port publié sur le LAN (tout lié à 127.0.0.1).
- Cibles sans egress (réseau internal).
- Identifiants fictifs, données fictives.
- Périmètre : le laboratoire uniquement.

## Snapshots
- Docker Compose : `make reset` (rebuild propre) ; chaque cible est
  reproductible par `docker compose restart <service>`.
EOF
echo "--- 3. Fiche générée ---"
cat "$FICHE"

echo
echo "--- Vérifications ---"
docker compose ps --format '{{.Name}}' | grep -q "seclab-vuln-host" && echo "✓ labo démarré (vuln-host présent)" || { echo "✗ vuln-host absent (make up-pentest)"; fail=1; }
docker compose ps --format '{{.Name}}' | grep -q "seclab-edge" && echo "✓ passerelle edge présente" || { echo "✗ edge absent"; fail=1; }
grep -q "seclab-internal" "$FICHE" && echo "✓ réseau interne documenté" || { echo "✗ réseau interne absent de la fiche"; fail=1; }
grep -q "vuln-host" "$FICHE" && echo "✓ machines documentées (vuln-host)" || { echo "✗ machines absentes"; fail=1; }
grep -q "127.0.0.1" "$FICHE" && echo "✓ règle : ports liés à 127.0.0.1" || { echo "✗ règle d'exposition absente"; fail=1; }
grep -q "Périmètre" "$FICHE" && echo "✓ périmètre documenté" || { echo "✗ périmètre absent"; fail=1; }

echo
if [ "$fail" -eq 0 ]; then
  echo "✅ Ch31 Ex1 : VALIDÉ"
else
  echo "❌ Ch31 Ex1 : ÉCHEC"
  exit 1
fi
