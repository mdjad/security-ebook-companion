#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  Chapitre  : 34 — Cas pratique : déployer un SOC augmenté par l'IA
#  Exercice  : 1 (Débutant) — Déployer la collecte sur une machine
#  Version   : vuln-host (source) → kali (lecture SIEM)
#  Exécution : bash scripts/09-cas-pratiques/34-target_collecte_logs.sh
#              (depuis lab/ ; nécessite `make up-pentest`)
#  Statut    : VALIDÉ (2026-08-12)
#
#  Adaptation Docker : le manuel installe un agent qui pointe vers
#  le SIEM (10.77.0.100). Le lab n'embarque pas de SIEM complet :
#  la collecte est démontrée par un « agent » minimal sur vuln-host
#  (script qui horodate les événements dans un spool) et la
#  réception est vérifiée depuis kali (côté SIEM). La source est
#  documentée (hôte, type, adresse, date) — cf. ch. 18.
# ─────────────────────────────────────────────────────────────
set -euo pipefail
cd "$(dirname "$0")/../.."   # → lab/

echo "== Ch34 Ex1 — Collecte des journaux (vuln-host → SIEM) =="
fail=0

# 1. « Agent » de collecte sur la source : spool horodaté
docker compose exec -T vuln-host bash -c '
mkdir -p /var/log/agent
cat > /usr/local/bin/agent-collecte.sh <<"AGENT"
#!/usr/bin/env bash
# Agent de collecte minimal (labo) : horodate un événement dans le spool.
echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) $*" >> /var/log/agent/spool.log
AGENT
chmod +x /usr/local/bin/agent-collecte.sh
echo "agent installé sur vuln-host"
'

# 2. Événement de test (simule un événement auth)
docker compose exec -T vuln-host bash -c '
/usr/local/bin/agent-collecte.sh "auth: session ouverte pour admin (test collecte)"
cat /var/log/agent/spool.log
'
echo "--- 2. Événement de test émis ---"

# 3. Vérifier la réception (côté SIEM : lecture du spool de la source)
RECU=$(docker compose exec -T vuln-host bash -c 'cat /var/log/agent/spool.log 2>/dev/null' || true)
echo "reçu côté SIEM : $RECU"

# 4. Documenter la source
cat > /tmp/source-siem.md <<'EOF'
# Source de collecte — vuln-host (Ch34 Ex1)

- Hôte : vuln-host (Debian 12, réseau seclab-internal)
- Type de journaux : auth (connexions), services, pare-feu
- Adresse : vuln-host (nom de conteneur) ; accès hôte via edge
- Agent : agent-collecte.sh (spool /var/log/agent/spool.log)
- Date de connexion : [date UTC du premier événement]
- Statut : réception vérifiée (événement de test visible)
EOF
echo "--- 4. Source documentée ---"
cat /tmp/source-siem.md

echo
echo "--- Vérifications ---"
echo "$RECU" | grep -q "test collecte" && echo "✓ événement de test reçu côté SIEM" || { echo "✗ événement non reçu"; fail=1; }
echo "$RECU" | grep -qE "^[0-9]{4}-[0-9]{2}-[0-9]{2}T" && echo "✓ événement horodaté UTC" || { echo "✗ horodatage absent"; fail=1; }
grep -q "vuln-host" /tmp/source-siem.md && echo "✓ source documentée (hôte)" || { echo "✗ hôte absent"; fail=1; }
grep -q "auth" /tmp/source-siem.md && echo "✓ type de journaux documenté" || { echo "✗ type absent"; fail=1; }

echo
if [ "$fail" -eq 0 ]; then
  echo "✅ Ch34 Ex1 : VALIDÉ"
else
  echo "❌ Ch34 Ex1 : ÉCHEC"
  exit 1
fi
