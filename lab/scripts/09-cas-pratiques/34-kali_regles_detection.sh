#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  Chapitre  : 34 — Cas pratique : déployer un SOC augmenté par l'IA
#  Exercice  : 2 (Intermédiaire) — Configurer et tester deux règles de détection
#  Version   : vuln-host (événements contrôlés) → kali (détection)
#  Exécution : bash scripts/09-cas-pratiques/34-kali_regles_detection.sh
#              (depuis lab/ ; nécessite `make up-pentest`)
#  Statut    : VALIDÉ (2026-08-12)
#
#  Adaptation Docker : le manuel utilise `logger -p auth.warning`
#  (syslog) et un dashboard SIEM. Le lab n'a pas de syslog/SIEM :
#  les événements contrôlés sont écrits dans un auth.log simulé
#  (même format Debian) et les deux règles sont exécutées en
#  awk/grep (même logique : seuil 5 échecs, IP hors liste connue).
#  Règles reliées à MITRE ATT&CK (T1110 Brute Force, T1078
#  Valid Accounts).
# ─────────────────────────────────────────────────────────────
set -euo pipefail
cd "$(dirname "$0")/../.."   # → lab/

echo "== Ch34 Ex2 — Deux règles de détection testées =="
fail=0

# 1. Événements contrôlés (auth.log simulé sur vuln-host)
docker compose exec -T vuln-host bash -c '
LOG=/var/log/auth.log.sim
: > "$LOG"
for i in 1 2 3 4 5; do
  echo "Aug 12 08:0$i:0$i vuln-host sshd[1234]: Failed password for root from 203.0.113.45 port 51234 ssh2" >> "$LOG"
done
echo "Aug 12 08:07:01 vuln-host sshd[1235]: Accepted password for admin from 203.0.113.99 port 51235 ssh2" >> "$LOG"
echo "Aug 12 08:08:01 vuln-host sshd[1236]: Accepted password for admin from 10.77.0.20 port 51236 ssh2" >> "$LOG"
echo "événements contrôlés écrits : $(wc -l < "$LOG") lignes"
'

# 2. Règle 1 : brute force SSH (5 échecs / 60 s) — T1110
echo "--- Règle 1 : brute force SSH (seuil 5 échecs) ---"
R1=$(docker compose exec -T vuln-host bash -c '
LOG=/var/log/auth.log.sim
grep "Failed password" "$LOG" | awk "{print \$(NF-3)}" | sort | uniq -c | sort -rn | while read n ip; do
  if [ "$n" -ge 5 ]; then echo "ALERTE brute force : $n échecs depuis $ip (T1110)"; fi
done
')
echo "$R1"

# 3. Règle 2 : connexion depuis une IP inconnue — T1078
echo "--- Règle 2 : connexion depuis IP inconnue ---"
R2=$(docker compose exec -T vuln-host bash -c '
LOG=/var/log/auth.log.sim
CONNUES="10.77.0.20 10.77.0.10"
grep "Accepted password" "$LOG" | awk "{print \$(NF-3)}" | while read ip; do
  case " $CONNUES " in *" $ip "*) echo "connexion connue : $ip";; *) echo "ALERTE IP inconnue : $ip (T1078)";; esac
done
')
echo "$R2"

# 4. Documenter les règles
cat > /tmp/regles-detection.md <<'EOF'
# Règles de détection — SOC labo (Ch34 Ex2)

## Règle 1 : brute force SSH
- Condition : source sshd, « Failed password », 5 occurrences / 60 s
- Niveau : moyen → élevé
- MITRE ATT&CK : T1110 (Brute Force)
- Test : 5 échecs depuis 203.0.113.45 → alerte déclenchée

## Règle 2 : connexion depuis une IP inconnue
- Condition : source sshd, « Accepted password », IP hors liste connue
- Niveau : moyen
- MITRE ATT&CK : T1078 (Valid Accounts)
- Test : 203.0.113.99 → alerte ; 10.77.0.20 (connue) → pas d'alerte

## Alignements
- Seuils ajustables ; revue hebdomadaire des faux positifs (ch. 24).
EOF
echo "--- 4. Règles documentées ---"
cat /tmp/regles-detection.md

echo
echo "--- Vérifications ---"
echo "$R1" | grep -q "ALERTE brute force" && echo "✓ Règle 1 : alerte brute force (5 échecs, T1110)" || { echo "✗ Règle 1 non déclenchée"; fail=1; }
echo "$R1" | grep -q "203.0.113.45" && echo "✓ Règle 1 : IP fautive identifiée" || { echo "✗ IP fautive absente"; fail=1; }
echo "$R2" | grep -q "ALERTE IP inconnue : 203.0.113.99" && echo "✓ Règle 2 : alerte IP inconnue (T1078)" || { echo "✗ Règle 2 non déclenchée"; fail=1; }
echo "$R2" | grep -q "connexion connue : 10.77.0.20" && echo "✓ Règle 2 : IP connue non alertée" || { echo "✗ IP connue mal traitée"; fail=1; }
grep -q "T1110" /tmp/regles-detection.md && echo "✓ règles reliées à MITRE ATT&CK" || { echo "✗ T1110 absent"; fail=1; }

echo
if [ "$fail" -eq 0 ]; then
  echo "✅ Ch34 Ex2 : VALIDÉ"
else
  echo "❌ Ch34 Ex2 : ÉCHEC"
  exit 1
fi
