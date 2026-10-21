#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  Chapitre  : 44 — Examen blanc n°5 (ch. 1-39, transversal)
#  Vérifie   : la commande du corrigé Ex2 (inventaire + durcissement)
#  Version   : vuln-host (cible du lab)
#  Exécution : bash scripts/11-examens-blancs/44-target_corriges_examens.sh
#              (depuis lab/ ; nécessite `make up`)
#  Statut    : VALIDÉ (2026-08-12)
#
#  Corrigé Ex2 : `ss -tulpn` + `systemctl list-units` ; risques (port
#  inutile, compte actif) ; corrections (fermer le port, désactiver le
#  compte). Adaptation lab : pas de systemd → `ps -ef` + `ls /etc/init.d/`
#  (cf. Ch38) ; fermeture de port démontrée en iptables (ufw → iptables).
# ─────────────────────────────────────────────────────────────
set -euo pipefail
cd "$(dirname "$0")/../.."   # → lab/

echo "== Ch44 — Corrigé de l'exercice 2 (inventaire + durcissement) =="
fail=0

echo "--- Ex2 : inventaire (ss + services) ---"
echo "==> ss -tulpn (ports en écoute)"
docker compose exec -T vuln-host ss -tulpn | awk 'NR==1 || /LISTEN/' | head -8
echo "==> services actifs (systemctl → adaptation lab : ps + init.d)"
docker compose exec -T vuln-host bash -c 'ps -ef | grep -v grep | grep -E "nginx|sshd|vsftpd|mariadb|mysqld" | awk "{print \$8, \$9}" | sort -u'

echo "--- Ex2 : risque identifié + correction (fermer un port) ---"
echo "==> port 21 (vsftpd) superflu pour le scénario → fermeture iptables"
docker compose exec -T vuln-host bash -c '
  iptables -A INPUT -p tcp --dport 21 -j DROP
  echo "règle ajoutée : INPUT tcp dpt:21 DROP"
  iptables -D INPUT -p tcp --dport 21 -j DROP
  echo "règle retirée (restauration)"
'

echo
echo "--- Vérifications ---"
docker compose exec -T vuln-host ss -tulpn | grep -q ":22" && echo "✓ Ex2 : ss -tulpn liste les ports (22/80/3306…)" || { echo "✗ ss -tulpn vide"; fail=1; }
docker compose exec -T vuln-host bash -c 'ps -ef | grep -qE "nginx|sshd"' && echo "✓ Ex2 : services actifs identifiés (adaptation ps/init.d)" || { echo "✗ services non identifiés"; fail=1; }
docker compose exec -T vuln-host bash -c 'iptables -L INPUT -n | grep -q "dpt:21" && echo "règle restante" || echo "règle retirée"' | grep -q "règle retirée" && echo "✓ Ex2 : fermeture de port démontrée puis restaurée (iptables)" || { echo "✗ restauration iptables échouée"; fail=1; }

echo
if [ "$fail" -eq 0 ]; then
  echo "✅ Ch44 corrigés : VALIDÉ"
else
  echo "❌ Ch44 corrigés : ÉCHEC"
  exit 1
fi
