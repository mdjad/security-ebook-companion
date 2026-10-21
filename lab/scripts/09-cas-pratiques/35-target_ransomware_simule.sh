#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  Chapitre  : 35 — Cas pratique : réponse à incident à l'ère de l'IA
#  Exercice  : 2 (Intermédiaire) — Répondre à un ransomware simulé (labo)
#  Version   : vuln-host (incident simulé) + kali (vérif isolation)
#  Exécution : bash scripts/09-cas-pratiques/35-target_ransomware_simule.sh
#              (depuis lab/ ; nécessite `make up-pentest`)
#  Statut    : VALIDÉ (2026-08-12)
#
#  Cycle complet (fidèle au manuel) : détection → contenance →
#  preuves (chaîne de garde) → analyse (strings) → éradication →
#  restauration → journal documenté. Aucune donnée réelle.
#
#  Adaptations Docker :
#    - Contenance : le manuel fait `ip link set eth1 down` ; dans le
#      lab, l'isolation est simulée par iptables DROP (INPUT/OUTPUT)
#      sur vuln-host, vérifiée depuis kali (nc échoue). docker exec
#      reste possible (il n'emprunte pas le réseau du conteneur).
#    - sha256sum : version corrigée (find ! -name hashes.txt, cf.
#      correction #32) pour éviter l'auto-référence.
# ─────────────────────────────────────────────────────────────
set -euo pipefail
cd "$(dirname "$0")/../.."   # → lab/

echo "== Ch35 Ex2 — Ransomware simulé : cycle complet =="
fail=0
JOURNAL=/var/log/incident/journal-incident.txt

# Filet de sécurité : restaurer le réseau même en cas d'échec
restore_net() {
  docker compose exec -T vuln-host bash -c 'iptables -F && iptables -P INPUT ACCEPT && iptables -P OUTPUT ACCEPT' 2>/dev/null || true
}
trap restore_net EXIT

# 0. Préparer l'incident simulé (fichiers « chiffrés » + artefact)
docker compose exec -T vuln-host bash -c '
rm -rf /var/tmp/incident /var/log/incident /mnt/preuves
mkdir -p /var/tmp/incident /var/log/incident /mnt/preuves
# données de travail (avant incident)
echo "rapport mensuel" > /var/tmp/incident/rapport.txt
echo "facture client" > /var/tmp/incident/facture.txt
# « chiffrement » simulé : renommage + contenu chiffré
for f in rapport facture; do
  mv /var/tmp/incident/$f.txt /var/tmp/incident/$f.txt.encrypted
  echo "ENCRYPTED-$(head -c 16 /dev/urandom | base64)" > /var/tmp/incident/$f.txt.encrypted
done
# artefact binaire (point d entrée simulé)
printf "MZ fake payload\nhttp://evil.example/payload\ntoken=sk-lab-abc123\n" > /var/tmp/incident/artefact.bin
echo "incident simulé : $(ls /var/tmp/incident | wc -l) fichiers"
'

# 1. Détection : chiffrement massif (extension .encrypted)
echo "--- 1. Détection ---"
DET=$(docker compose exec -T vuln-host bash -c 'find /var/tmp/incident -name "*.encrypted" | wc -l')
echo "fichiers .encrypted détectés : $DET"
docker compose exec -T vuln-host bash -c "echo \"\$(date -u) : alerte SOC - chiffrement massif ($DET fichiers)\" >> $JOURNAL"

# 2. Contenance : isolation réseau (iptables DROP)
echo "--- 2. Contenance (isolation) ---"
docker compose exec -T vuln-host bash -c '
iptables -P INPUT DROP
iptables -P OUTPUT DROP
echo "$(date -u) : isolation réseau (iptables DROP)" >> /var/log/incident/journal-incident.txt
'
ISO=$(docker compose exec -T kali bash -c 'nc -z -w 2 vuln-host 80 2>/dev/null && echo "JOIGNABLE" || echo "ISOLE"' || true)
echo "depuis kali : vuln-host $ISO"

# 3. Preuves (chaîne de garde)
echo "--- 3. Preuves (chaîne de garde) ---"
docker compose exec -T vuln-host bash -c '
DEST=/mnt/preuves/$(date +%F)
mkdir -p "$DEST"
cp -r /var/tmp/incident "$DEST/"
date -u > "$DEST/horodatage.txt"
find "$DEST" -type f ! -name hashes.txt -exec sha256sum {} + > "$DEST/hashes.txt"
echo "preuves : $(wc -l < "$DEST/hashes.txt") fichiers hachés"
cat "$DEST/hashes.txt"
'

# 4. Analyse : point d entrée (strings + IoC)
echo "--- 4. Analyse (strings artefact) ---"
ANALYSE=$(docker compose exec -T vuln-host bash -c 'grep -a -iE "http|token" /mnt/preuves/$(date +%F)/incident/artefact.bin')
echo "$ANALYSE"
docker compose exec -T vuln-host bash -c "echo \"\$(date -u) : analyse - IoC identifiés (http, token)\" >> $JOURNAL"

# 5. Éradication (simulée) : suppression des fichiers chiffrés
echo "--- 5. Éradication (simulée) ---"
docker compose exec -T vuln-host bash -c '
rm -f /var/tmp/incident/*.encrypted /var/tmp/incident/artefact.bin
echo "$(date -u) : éradication - fichiers chiffrés supprimés" >> /var/log/incident/journal-incident.txt
echo "restant : $(ls /var/tmp/incident | wc -l) fichiers"
'

# 6. Récupération : restauration depuis les sauvegardes (3-2-1)
echo "--- 6. Récupération (sauvegarde 3-2-1) ---"
docker compose exec -T vuln-host bash -c '
mkdir -p /var/backups/incident
echo "rapport mensuel" > /var/backups/incident/rapport.txt
echo "facture client" > /var/backups/incident/facture.txt
cp /var/backups/incident/*.txt /var/tmp/incident/
echo "$(date -u) : restauration depuis sauvegarde testée" >> /var/log/incident/journal-incident.txt
ls /var/tmp/incident/
'

# 7. Fin de l isolation (restauration réseau)
docker compose exec -T vuln-host bash -c '
iptables -F && iptables -P INPUT ACCEPT && iptables -P OUTPUT ACCEPT
echo "$(date -u) : fin d isolation - surveillance renforcée" >> /var/log/incident/journal-incident.txt
'
echo "--- 7. Isolation levée, journal complet ---"
docker compose exec -T vuln-host bash -c 'cat /var/log/incident/journal-incident.txt'

echo
echo "--- Vérifications ---"
[ "$DET" -ge 2 ] && echo "✓ détection : chiffrement massif identifié" || { echo "✗ détection absente"; fail=1; }
echo "$ISO" | grep -q "ISOLE" && echo "✓ contenance : vuln-host isolé (nc échoue)" || { echo "✗ isolation non vérifiée"; fail=1; }
docker compose exec -T vuln-host bash -c 'test -s /mnt/preuves/$(date +%F)/hashes.txt' && echo "✓ preuves : hashes.txt non vide (chaîne de garde)" || { echo "✗ preuves absentes"; fail=1; }
echo "$ANALYSE" | grep -q "http://evil.example" && echo "✓ analyse : IoC http identifié (strings)" || { echo "✗ IoC absent"; fail=1; }
docker compose exec -T vuln-host bash -c 'ls /var/tmp/incident/rapport.txt >/dev/null 2>&1' && echo "✓ récupération : rapport.txt restauré" || { echo "✗ restauration absente"; fail=1; }
docker compose exec -T vuln-host bash -c 'grep -q "isolation réseau" /var/log/incident/journal-incident.txt' && echo "✓ journal : isolation documentée" || { echo "✗ journal incomplet"; fail=1; }

echo
if [ "$fail" -eq 0 ]; then
  echo "✅ Ch35 Ex2 : VALIDÉ"
else
  echo "❌ Ch35 Ex2 : ÉCHEC"
  exit 1
fi
