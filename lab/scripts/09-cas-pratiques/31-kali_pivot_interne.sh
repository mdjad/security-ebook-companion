#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  Chapitre  : 31 — Cas pratique : construire un laboratoire de pentest
#  Exercice  : 3 (Confirmé) — Simuler un pivot interne (labo uniquement)
#  Version   : kali → vuln-host (serveur compromis) → web-lab (machine interne)
#  Exécution : bash scripts/09-cas-pratiques/31-kali_pivot_interne.sh
#              (depuis lab/ ; nécessite `make up-pentest`)
#  Statut    : VALIDÉ (2026-08-12)
#
#  Adaptation Docker : kali est sur les 2 réseaux ; pour **démontrer
#  la technique** de pivot (ssh -L à travers le serveur compromis), le
#  script ouvre un tunnel via vuln-host vers web-lab (machine interne)
#  et prouve l'accès au service interne. Aucune donnée réelle ; leçon
#  = pourquoi on segmente (ch. 17, 21).
# ─────────────────────────────────────────────────────────────
set -euo pipefail
cd "$(dirname "$0")/../.."   # → lab/

echo "== Ch31 Ex3 — Pivot interne (tunnel ssh -L) =="
fail=0

# 1. Clé SSH idempotente sur kali + installation sur vuln-host (admin)
docker compose exec -T kali bash -c '[ -f /tmp/pivot_key ] || ssh-keygen -t ed25519 -N "" -f /tmp/pivot_key -q'
KEY=$(docker compose exec -T kali cat /tmp/pivot_key.pub)
docker compose exec -T vuln-host bash -c "
  mkdir -p /home/admin/.ssh
  echo '$KEY' > /home/admin/.ssh/authorized_keys
  chown -R admin:admin /home/admin/.ssh
  chmod 700 /home/admin/.ssh
  chmod 600 /home/admin/.ssh/authorized_keys
"
echo "--- 1. Clé installée sur vuln-host (admin) ---"

# 2. Tunnel ssh -L depuis kali via vuln-host vers web-lab:80
#    (exec -d : session détachée, sinon le tunnel est tué à la fin de l'exec ;
#     [s]sh : le motif ne matche pas la ligne de commande de pkill lui-même)
docker compose exec -T kali bash -c 'pkill -f "[s]sh -N.*18085" 2>/dev/null || true'
docker compose exec -d kali bash -c 'ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i /tmp/pivot_key -N -L 18085:web-lab:80 admin@vuln-host'
sleep 2
echo "--- 2. Tunnel établi (kali:18085 → vuln-host → web-lab:80) ---"

# 3. Vérifier l accès au service interne via le tunnel
CODE=$(docker compose exec -T kali bash -c 'curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:18085/' 2>/dev/null || echo "000")
echo "HTTP code via tunnel : $CODE"

# 4. Preuve documentée
cat > /tmp/preuve-pivot.md <<'EOF'
# Preuve de pivot (labo uniquement)

- Technique : tunnel SSH (-L) à travers le serveur compromis (vuln-host).
- Cible : web-lab (machine interne, port 80).
- Résultat : le service interne est accessible depuis le poste d attaque
  via le tunnel (HTTP 200).
- Leçon : sans segmentation (ch. 17, 21), un serveur compromis donne
  accès aux segments internes.
- Remédiation : segmentation + surveillance (ch. 18, 34).
EOF

echo "--- 4. Preuve documentée ---"
cat /tmp/preuve-pivot.md

# Nettoyage : fermer le tunnel
docker compose exec -T kali bash -c 'pkill -f "[s]sh -N.*18085" 2>/dev/null || true' || true

echo
echo "--- Vérifications ---"
[ "$CODE" = "200" ] && echo "✓ service interne accessible via le tunnel (HTTP 200)" || { echo "✗ tunnel non fonctionnel (code $CODE)"; fail=1; }
grep -q "web-lab" /tmp/preuve-pivot.md && echo "✓ preuve documentée (cible web-lab)" || { echo "✗ preuve absente"; fail=1; }
grep -q "segmentation" /tmp/preuve-pivot.md && echo "✓ leçon : segmentation (ch. 17, 21)" || { echo "✗ leçon absente"; fail=1; }

echo
if [ "$fail" -eq 0 ]; then
  echo "✅ Ch31 Ex3 : VALIDÉ"
else
  echo "❌ Ch31 Ex3 : ÉCHEC"
  exit 1
fi
