# Journal de validation du laboratoire

Ce journal trace **chaque script testé** dans le laboratoire et **toute correction apportée au
manuel** (éditions `fr/` et `en/`) lorsque la réalité diffère du texte publié.

## Légende

- ✅ **VALIDÉ** — le script s'exécute et produit la sortie attendue.
- ⚠️ **CORRIGÉ** — un écart manuel/réel a été constaté ; le manuel (fr + en) a été mis à jour.
- 🔧 **ADAPTÉ** — le script adapte le manuel au contexte Docker (ex. IP VirtualBox → noms de
  conteneurs) sans changer le fond ; l'adaptation est documentée ici.

## Table de validation

| Script | Chapitre | Statut | Date | Écart constaté | Correction livre (fr/ + en/) |
|—-|—-|—-|—-|—-|—-|
| `06-target_inventaire_securite.sh` | Ch06 Ex1 | ✅ VALIDÉ | 2026-08-11 | `systemctl`/`journalctl` absents (conteneur sans systemd) → `ps -ef` + fixture `auth.log` | 🔧 note lab |
| `06-target_audit_sudo.sh` | Ch06 Ex2 | ✅ VALIDÉ | 2026-08-11 | groupe `ssh` absent sur Debian (c'est `_ssh`) | ⚠️ note portabilité Ubuntu/Debian |
| `07-kali_tcpdump_http.sh` | Ch07 Ex1 | ✅ VALIDÉ | 2026-10-21 | Kali multi-réseaux : `eth0` n'était pas stable et le DNS Docker (127.0.0.11) répond en userspace ; capture `any` filtrée sur TCP/80 vers `vuln-host`, résolution vérifiée séparément | 🔧 adaptation lab Docker |
| `07-kali_diagnostic_couches.sh` | Ch07 Ex2 | ✅ VALIDÉ | 2026-08-11 | kali sur 2 réseaux → trafic cible via `eth1` (`-i any`) | 🔧 note lab |
| `08-host_topologie_lab.sh` | Ch08 Ex1 | ✅ VALIDÉ | 2026-08-11 | le labo Docker remplace VirtualBox (équivalent fonctionnel) | 🔧 note lab |
| `08-host_scenario_incident.sh` | Ch08 Ex2 | ✅ VALIDÉ | 2026-08-11 | bruit ARP/IPv6 sur réseau interne → filtre tcpdump ports 80/3306 | 🔧 note lab |
| `09-kali_script_bash_ssh.sh` | Ch09 Ex1 | ✅ VALIDÉ | 2026-08-11 | `journalctl` absent → fixture `auth.log` (même pipeline grep/awk/sort/uniq) | 🔧 note lab |
| `09-kali_analyseur_python.sh` | Ch09 Ex2 | ✅ VALIDÉ | 2026-08-11 | script Python du manuel exécuté tel quel sur la fixture | — |
| `10-kali_nmap_laboratoire.sh` | Ch10 Ex1 | ✅ VALIDÉ | 2026-08-11 | réseau interne en /16 → scan du /24 réel des cibles | 🔧 note lab |
| `10-zap_dvwa_scan.sh` | Ch10 Ex2 | ✅ VALIDÉ | 2026-08-11 | ZAP en daemon (API REST) ; scan actif complet DVWA ~10 min → spider + scan passif (équivalent `-quickurl`) | 🔧 note lab |
| `11-kali_metasploit_ssh.sh` | Ch11 Ex1 | ✅ VALIDÉ | 2026-08-11 | msfconsole scripté `-q -x` (séparateurs `;`) | 🔧 note lab |
| `11-kali_fiche_vulnerabilite.sh` | Ch11 Ex2 | ✅ VALIDÉ | 2026-08-11 | fiche générée à partir du scan réel (nginx 1.22.1) | — |
| `12-kali_openssl_crypto.sh` | Ch12 Ex1 | ⚠️ CORRIGÉ | 2026-08-11 | `openssl enc -aes-256-gcm` → **AEAD non supporté** (OpenSSL 3.6.3) → `-aes-256-cbc` | ⚠️ corrigé fr+en (correction #19) |
| `12-kali_audit_tls.sh` | Ch12 Ex2 | ✅ VALIDÉ | 2026-08-11 | TLS 1.0 rejeté : `CONNECTED` ne prouve que TCP ; l'alerte `tlsv1 alert protocol version` (70) confirme le rejet | 🔧 note lab |
| `13-kali_pass_coffre.sh` | Ch13 Ex1 | ✅ VALIDÉ | 2026-08-12 | `pass`/`gpg` absents de l'image Kali → ajoutés au Dockerfile ; `file` retourne `PGP RSA encrypted session key` (pas « data ») | 🔧 note lab |
| `13-kali_sauvegarde_321.sh` | Ch13 Ex2 | ⚠️ CORRIGÉ | 2026-08-11 | `openssl enc -aes-256-gcm` → `-aes-256-cbc` (même correction que Ch12) | ⚠️ corrigé fr+en (correction #19) |
| `14-kali_cadre_engagement.sh` | Ch14 Ex1 | ✅ VALIDÉ | 2026-08-12 | « Exclusions » promu en section `##` propre (le grep attendait `^## Exclusions`) | 🔧 note lab |
| `14-kali_plan_mission.sh` | Ch14 Ex2 | ✅ VALIDÉ | 2026-08-12 | document généré + structure vérifiée (objectifs, phases, livrables, risques) | — |
| `15-kali_recon_scan.sh` | Ch15 Ex1 | ✅ VALIDÉ | 2026-08-12 | réseau interne en /16 → /24 dérivé de `getent hosts vuln-host` | 🔧 note lab |
| `15-kali_version_cve.sh` | Ch15 Ex2 | ✅ VALIDÉ | 2026-08-12 | repro nginx 1.22.1 déjà en place ; constat VULN-2026-002 généré | — |
| `16-kali_suid_vecteur.sh` | Ch16 Ex1 | ✅ VALIDÉ | 2026-08-12 | SUID anormal `backup-helper` ; `find / -perm -4000` → `|| true` (traversée /proc) | 🔧 note lab |
| `16-kali_rapport_pentest.sh` | Ch16 Ex2 | ✅ VALIDÉ | 2026-08-12 | rapport généré à partir de constats réels (nginx, en-têtes, port superflu) | — |
| `27-host_en_tetes_web.sh` | Ch27 Ex1 | ✅ VALIDÉ | 2026-08-12 | en-têtes pilotés par `SECURITY_HEADERS` (off/on) via edge `127.0.0.1:18084` | 🔧 note lab |
| `27-kali_authz_idor.sh` | Ch27 Ex2 | ✅ VALIDÉ | 2026-08-12 | correction côté serveur pilotée par `VULN_MODE=fixed` (200 → 403) | 🔧 note lab |
| `28-kali_api_surexposition.sh` | Ch28 Ex1 | ✅ VALIDÉ | 2026-08-12 | sérialisation liste blanche via `VULN_MODE=fixed` (champs internes retirés) | 🔧 note lab |
| `28-kali_api_bola.sh` | Ch28 Ex2 | ✅ VALIDÉ | 2026-08-12 | vérification de propriétaire via `VULN_MODE=fixed` (200 → 403) | 🔧 note lab |
| `29-host_responsabilite_partagee.sh` | Ch29 Ex1 | ✅ VALIDÉ | 2026-08-12 | exercice document → validation par modèle de structure (PaaS/IaaS) | — |
| `29-devsecops_dockerfile_scan.sh` | Ch29 Ex2 | ✅ VALIDÉ | 2026-08-12 | image construite via docker.sock ; DL3008 = constat restant (épingler versions apt) | 🔧 note lab |
| `30-devsecops_scan_depot.sh` | Ch30 Ex1 | ✅ VALIDÉ | 2026-08-12 | secret retiré du fichier ≠ purgé de l'historique (leçon démontrée) | 🔧 note lab |
| `30-devsecops_pipeline.sh` | Ch30 Ex2 | ✅ VALIDÉ | 2026-08-12 | `act —list` (pas d'exécution complète) ; cosign sans tlog ; IaC sur copie /tmp | 🔧 note lab |
| `17-target_surface_attaque.sh` | Ch17 Ex1 | ✅ VALIDÉ | 2026-08-12 | `systemctl`/`journalctl` absents (conteneur sans systemd) → `pkill`/`service` ; rpcbind/cups/avahi absents → surface = vsftpd | 🔧 note lab |
| `17-host_durcissement_ssh.sh` | Ch17 Ex2 | ✅ VALIDÉ | 2026-08-12 | `ufw` → `iptables` (même politique : refuser entrant, autoriser 22/443) ; `PermitRootLogin no` bloque aussi la clé root → test clé sur `admin` ; hydra avant/après | 🔧 note lab |
| `18-kali_analyse_logs_ssh.sh` | Ch18 Ex1 | ✅ VALIDÉ | 2026-08-12 | `journalctl` absent → fixture `auth.log` (29 échecs, IP 203.0.113.10) ; règle T1110 | 🔧 note lab |
| `18-host_regle_correlation.sh` | Ch18 Ex2 | ✅ VALIDÉ | 2026-08-12 | exercice document → validation par modèle de structure (événements, condition, niveau, action) | — |
| `19-host_collecte_preuves.sh` | Ch19 Ex1 | ✅ VALIDÉ | 2026-08-12 | `journalctl -u sshd` → fixture `auth.log` ; `sha256sum` auto-référent corrigé (hacher les pièces, pas `hashes.txt`) | 🔧 note lab |
| `19-host_plan_reponse_rex.sh` | Ch19 Ex2 | ✅ VALIDÉ | 2026-08-12 | exercice document → playbook 5 phases + REX (causes racines, actions) | — |
| `20-target_cycle_vie_identite.sh` | Ch20 Ex1 | ✅ VALIDÉ | 2026-08-12 | message sudo en anglais (locale EN) → grep `not allowed to run sudo` | 🔧 note lab |
| `20-target_audit_annuaire.sh` | Ch20 Ex2 | ✅ VALIDÉ | 2026-08-12 | `samba-tool` (AD) → comptes Linux (même boucle : inventaire, dormants, moindre privilège) ; lastlog `Never logged in` | 🔧 note lab |
| `21-host_defense_reseau.sh` | Ch21 Ex1 | ✅ VALIDÉ | 2026-08-12 | `ufw` → `iptables` ; sous-réseau interne via `docker network inspect` ; vérif depuis kali (22 ouvert, 80/3306 fermés) | 🔧 note lab |
| `21-host_suricata_detection.sh` | Ch21 Ex2 | ✅ VALIDÉ | 2026-08-12 | suricata `jasonish` (AlmaLinux, `dnf`) ; règles locales SID 9000001-3 (pas d'ET : réseau interne sans Internet) ; fast.log + tcpdump | 🔧 note lab |
| `22-host_classifier_usages_ia.sh` | Ch22 Ex1 | ✅ VALIDÉ | 2026-08-12 | exercice document → tableau arme/bouclier/cible × technologie | — |
| `22-host_analyse_risques_ia.sh` | Ch22 Ex2 | ✅ VALIDÉ | 2026-08-12 | exercice document → analyse 5 dimensions (≥2 risques + recommandation) | — |
| `23-host_analyse_courriel.sh` | Ch23 Ex1 | ✅ VALIDÉ | 2026-08-12 | fixture `datasets/courriel-suspect.eml` ; mismatch Return-Path ≠ From ; vérification autre canal | 🔧 note lab |
| `23-host_scenario_exercice.sh` | Ch23 Ex2 | ✅ VALIDÉ | 2026-08-12 | exercice document → scénario d'exercice de phishing (cadre éthique) | — |
| `23-host_analyse_artefact.sh` | Ch23 Ex3 | ✅ VALIDÉ | 2026-08-12 | artefact fictif + `strings`/`grep` ; IoC + règles (T1059/T1105) + remédiation | — |
| `24-host_tri_alertes.sh` | Ch24 Ex1 | ✅ VALIDÉ | 2026-08-12 | 10 alertes fictives ; `sort|uniq -c|sort -rn` (rôle du tri IA) | — |
| `24-host_assistant_soc.sh` | Ch24 Ex2 | ✅ VALIDÉ | 2026-08-12 | exercice document → cahier des charges assistant SOC (rôle, périmètre, supervision, 3 métriques) | — |
| `24-host_mesure_faux_positifs.sh` | Ch24 Ex3 | ✅ VALIDÉ | 2026-08-12 | journal 20 alertes ; TP/FP/FN → précision 67 %, rappel 80 %, F1 ; supervision obligatoire | — |
| `25-host_points_fuite_ia.sh` | Ch25 Ex1 | ✅ VALIDÉ | 2026-08-12 | exercice document → carte des points de fuite d'un assistant RAG | — |
| `25-host_prompt_injection.sh` | Ch25 Ex2 | ✅ VALIDÉ | 2026-08-12 | `apps/llm-lab/assistant.py` (simulateur LLM) : fuite en mode vulnérable, refus en mode durci, question légitime servie | 🔧 note lab |
| `25-host_revue_securite_ia.sh` | Ch25 Ex3 | ✅ VALIDÉ | 2026-08-12 | exercice document → revue OWASP Top 10 for LLM (5 points, écarts, priorités datées) | — |
| `26-host_registre_usages_ia.sh` | Ch26 Ex1 | ✅ VALIDÉ | 2026-08-12 | registre CSV 3 usages ; classification risque → AIPD pour le risque élevé | — |
| `26-host_aipd.sh` | Ch26 Ex2 | ✅ VALIDÉ | 2026-08-12 | exercice document → AIPD tri de CV (traitement, données, risques, mesures, supervision, responsables) | — |
| `26-host_gouvernance_ia.sh` | Ch26 Ex3 | ✅ VALIDÉ | 2026-08-12 | exercice document → plan de gouvernance (7 sections) + feuille de route datée | — |
| `31-host_fiche_laboratoire.sh` | Ch31 Ex1 | ✅ VALIDÉ | 2026-08-12 | lab Docker = équivalent fonctionnel de VirtualBox ; fiche (réseaux, machines, règles, snapshots) | 🔧 note lab |
| `31-kali_cycle_test.sh` | Ch31 Ex2 | ✅ VALIDÉ | 2026-08-12 | snapshot VirtualBox → `docker compose restart vuln-host` ; `date -u +%Y-%m-%dT%H:%M:%SZ` (format ISO) | 🔧 note lab |
| `31-kali_pivot_interne.sh` | Ch31 Ex3 | ✅ VALIDÉ | 2026-08-12 | kali sans sshpass → clé ed25519 écrite dans vuln-host ; tunnel `ssh -L 18085:web-lab:80` via `exec -d` (détaché) ; pkill `[s]sh` (auto-match) | 🔧 note lab |
| `32-host_regles_engagement.sh` | Ch32 Ex1 | ✅ VALIDÉ | 2026-08-12 | exercice document → règles d'engagement (cible, portée, fenêtre, contraintes, contacts) | — |
| `32-kali_constat_idor.sh` | Ch32 Ex2 | ✅ VALIDÉ | 2026-08-12 | BOLA démontré : jeton A → `/v1/customers/2` (propriétaire B) HTTP 200 ; constat VULN-001 | 🔧 note lab |
| `32-host_rapport_test.sh` | Ch32 Ex3 | ✅ VALIDÉ | 2026-08-12 | exercice document → rapport final (synthèse, périmètre, constats, priorités, re-test) | — |
| `33-target_audit_lynis.sh` | Ch33 Ex1 | ✅ VALIDÉ | 2026-08-12 | inventaire sans systemd (`ss` + init.d) ; lynis installé sur vuln-host ; top 5 écarts | 🔧 note lab |
| `33-target_durcissement_cycle.sh` | Ch33 Ex2 | ✅ VALIDÉ | 2026-08-12 | cycle complet (SSH, iptables, vsftpd, svc_backup, PAM) + restauration pour pentest | 🔧 note lab |
| `34-target_collecte_logs.sh` | Ch34 Ex1 | ✅ VALIDÉ | 2026-08-12 | pas de syslog/SIEM → agent minimal (spool horodaté) ; réception vérifiée | 🔧 note lab |
| `34-kali_regles_detection.sh` | Ch34 Ex2 | ✅ VALIDÉ | 2026-08-12 | `logger` sans syslog → auth.log simulé ; 2 règles (T1110, T1078) testées | 🔧 note lab |
| `34-host_assistant_soc_supervise.sh` | Ch34 Ex3 | ✅ VALIDÉ | 2026-08-12 | exercice document → assistant SOC supervisé (rôle, supervision, métriques, décision) | — |
| `35-host_demande_frauduleuse.sh` | Ch35 Ex1 | ✅ VALIDÉ | 2026-08-12 | exercice document → procédure anti-deepfake (canal distinct, preuves) | — |
| `35-target_ransomware_simule.sh` | Ch35 Ex2 | ✅ VALIDÉ | 2026-08-12 | `ip link down` → iptables DROP (docker exec reste possible) ; `strings` absent → `grep -a` ; trap restaure le réseau | 🔧 note lab |
| `35-host_rex_incident.sh` | Ch35 Ex3 | ✅ VALIDÉ | 2026-08-12 | exercice document → REX (chronologie, causes, actions datées, détection) | — |
| `36-host_classifier_usages_ia.sh` | Ch36 Ex1 | ✅ VALIDÉ | 2026-08-12 | exercice document → classification 3 usages (AI Act, AIPD) | — |
| `36-host_flux_garde_fous.sh` | Ch36 Ex2 | ✅ VALIDÉ | 2026-08-12 | audit secrets journaux + anti-prompt-injection (assistant.py) + moindre privilège ; `grep\|wc` avec `\|\| true` (pipefail) | 🔧 note lab |
| `36-host_gouvernance_surveillance.sh` | Ch36 Ex3 | ✅ VALIDÉ | 2026-08-12 | exercice document → gouvernance + plan de surveillance (registre, AIPD, SIEM, playbook) | — |
| `37-host_reviser_erreurs.sh` | Ch37 Ex1 | ✅ VALIDÉ | 2026-08-12 | exercice document → checklist section B + 3 actions reliées aux chapitres | — |
| `38-target_inventaire_5_commandes.sh` | Ch38 Ex1 | ✅ VALIDÉ | 2026-08-12 | hostnamectl/systemctl absents → os-release + init.d ; même inventaire en 5 commandes | 🔧 note lab |
| `38-target_durcir_ssh_memo.sh` | Ch38 Ex2 | ✅ VALIDÉ | 2026-08-12 | `systemctl reload sshd` → `sshd -t && kill -HUP` ; clé testée avant fermeture ; restauration | 🔧 note lab |
| `39-host_fiche_personnelle.sh` | Ch39 Ex1 | ✅ VALIDÉ | 2026-08-12 | exercice document → fiche « Mon poste de travail » (schéma, essentiel, pièges) | — |
| `39-host_reviser_fiches.sh` | Ch39 Ex2 | ✅ VALIDÉ | 2026-08-12 | exercice document → révision active (sélection, relue sans écran, compléments) | — |
| `40-target_corriges_examens.sh` | Ch40 Ex2+Ex4 | ✅ VALIDÉ | 2026-08-12 | corrigés vérifiés : `hostname -I`, `ss -tulpn`, `sha256sum` (OK) ; `systemctl` → adaptation ps/init.d | 🔧 note lab |
| `41-target_corriges_examens.sh` | Ch41 Ex2+Ex4 | ✅ VALIDÉ | 2026-08-12 | corrigés vérifiés : ufw (deny/allow/enable/status) testé puis restauré ; `tar` + `sha256sum -c` (OK) | 🔧 note lab |
| `42-host_corriges_examens.sh` | Ch42 Ex1 | ✅ VALIDÉ | 2026-08-12 | corrigé vérifié : `curl -I` via edge (HTTP 200) ; en-têtes de sécurité pilotés par SECURITY_HEADERS | 🔧 note lab |
| `43-host_corriges_examens.sh` | Ch43 Ex1-5 | ✅ VALIDÉ | 2026-08-12 | corrigés conceptuels (playbook, durcissement, tri IA, garde-fous, fraude) → validation par modèle de structure | — |
| `44-target_corriges_examens.sh` | Ch44 Ex2 | ✅ VALIDÉ | 2026-08-12 | corrigé vérifié : `ss -tulpn` + services (adaptation ps/init.d) ; fermeture de port démontrée en iptables puis restaurée | 🔧 note lab |

## Corrections connues à appliquer (détectées pendant la conception)

| # | Écart manuel / réel | Correction |
|—-|—-|—-|
| 1 | Le manuel utilise des IP VirtualBox `10.77.0.x` (Kali .10, cible .20) | Dans le lab Docker, les cibles sont joignables **par nom de conteneur** (`vuln-host`, `vuln-api`, `dvwa`, `juice-shop`, `web-lab`). Les scripts utilisent les noms ; le manuel gagne une note « lab Docker » le cas échéant. |
| 2 | Ch08 recommande `vulnerables/web-dvwa` | Image **amd64 uniquement** → sur Apple Silicon, utiliser `cytopia/dvwa:php-8.1` (multi-arch). **Note appliquée au manuel** (fr+en : Ch08, Ch10, Annexe-A). |
| 3 | `dnsutils` (paquet Kali) | N'existe pas sur Kali → **`bind9-dnsutils`**. |
| 4 | `hashcat` dans Docker sur macOS | Pas de GPU → **CPU uniquement** (via `pocl-opencl-icd`). Note à ajouter au manuel : John the Ripper recommandé pour le CPU. |
| 5 | ZAP en GUI | Dans le lab, ZAP tourne en **daemon** (API REST) ; l'interface web reste dispo sur `127.0.0.1:8090`. |
| 6 | `msfconsole` interactif | Scripté via **`msfconsole -q -x "..."`** (ou `-r script.rc`). Premier lancement lent (~10-30 s). |
| 7 | Module exploit Ch15 `exploit/linux/http/nginx_xxx` | **Fictif** (placeholder) → validé au niveau du scanner auxiliaire `auxiliary/scanner/ssh/ssh_version` ; le reste est illustratif. |
| 8 | `rockyou.txt` complet (~130 Mo) | Non redistribué → fixture réduite `datasets/wordlist.txt` + lien vers la source. |
| 9 | Accès hôte aux cibles | Les cibles sont sur un réseau `internal:true` (ports publiés non joignables sur Docker Desktop macOS) → accès via le service **`edge`** (`127.0.0.1:18081-18084`). |
| 10 | Commandes API du manuel : `curl -d '{"user":"A",...}'` sans `Content-Type: application/json` | `curl -d` envoie `application/x-www-form-urlencoded` ; une API JSON stricte renvoie 415/400. L'API du lab **accepte le JSON quel que soit le content-type** pour que les commandes du livre fonctionnent telles quelles. Bonne pratique à noter au manuel : toujours préciser `-H "Content-Type: application/json"`. |
| 11 | Ports hôte 8081-8084 | Collision avec d'autres projets (ex. `de-nginx` sur 8081) → plage **18081-18084** pour le lab. |
| 12 | Ch06 Ex2 : `getent group sudo adm ssh` | Le groupe `ssh` existe sur Ubuntu (contexte du manuel) mais **pas sur Debian** (sshd utilise `_ssh`). Sur la cible Debian du lab, on audite `sudo adm`. Note de portabilité à ajouter au manuel. |
| 13 | Ch07 Ex1 : la requête DNS Docker n'apparaît pas dans tcpdump | Le résolveur embarqué (127.0.0.11) répond en userspace. Dans le lab, vérifier la résolution avec `dig` séparément puis capturer la session HTTP vers `vuln-host` sur `any` ; ne pas dépendre d'un résolveur public ni d'une interface fixe. |
| 14 | Ch15/16 : MySQL joignable depuis le poste d'attaque | MariaDB écoute par défaut sur 127.0.0.1 → la cible « vulnérable » du lab force `bind-address = 0.0.0.0` pour que le port 3306 soit scannable (cohérent avec le scénario du manuel). |
| 15 | `find / -perm -4000` retourne 1 dans un conteneur | Erreurs de traversée sur `/proc` etc. même avec `2>/dev/null` → `|| true` dans les scripts de validation (le manuel reste correct sur un vrai système). |
| 16 | `pocl-opencl-icd` n'existe pas dans les dépôts Kali | Vérifié 2026-08 : Kali ne fournit pas pocl. Installé depuis **Debian trixie** avec pinning apt (priorité 100) + loader ICD `ocl-icd-libopencl1` (Kali). hashcat CPU fonctionne (22 H/s, lent mais OK). |
| 17 | ZAP daemon : l'API/UI n'est pas joignable depuis l'hôte (`127.0.0.1:8090`) | ZAP proxyifie toute requête dont le **Host header** ne correspond pas à son adresse (`zap:8080`). Depuis l'hôte, l'API répond avec `-H "Host: zap:8080"`. Les scripts de validation utilisent l'API **depuis le réseau interne** (`http://zap:8080/`), fiable. Note à ajouter au manuel/README. |
| 18 | Scan actif ZAP complet de DVWA | Dure ~10 min (toutes règles actives). Pour une validation rapide, spider + scan passif suffisent (340 alertes) — équivalent fonctionnel de `zap.sh -quickurl`. |
| 19 | Ch12 Ex1 & Ch13 Ex2 : `openssl enc -aes-256-gcm` | **Erreur réelle du manuel** : la commande `enc` d'OpenSSL ne supporte **pas** les ciphers AEAD (GCM). Vérifié OpenSSL 3.6.3 : `enc: AEAD ciphers not supported`. Le chiffrement par mot de passe passe par `-aes-256-cbc` (confidentialité seule) ; pour l'authentification, utiliser `gpg`/`age`/`openssl cms`. **Correction appliquée aux chapitres fr/ + en/.** |
| 20 | Ch13 Ex1 : `pass` et `gpg` absents de l'image Kali | L'image `pentest-toolbox` n'installait ni `pass` ni `gnupg` → `gpg: command not found`. Ajoutés au Dockerfile (`pass gnupg`). Vérifié : pass 1.7.4, gpg 2.4.9. |
| 21 | `make validate` échouait sur `10-zap_dvwa_scan.sh` | Le service `zap` (profil `web`) n'était pas démarré par `validate`. Le Makefile démarre désormais **tous les profils** (`up-pentest up-web up-devsecops`) avant d'exécuter les scripts. |
| 22 | Build `devsecops-toolbox` : `pip install semgrep checkov` | Debian bookworm = Python **externally managed** (PEP 668) → pip refuse l'installation système. Ajout de `—break-system-packages` (approche standard pour une image toolbox). |
| 23 | Ch30 Ex1 : gitleaks ne détecte pas le secret volontaire `sk-lab-…` | La valeur hexadécimale a une **entropie < seuil** de la règle générique et le préfixe `sk-lab-` n'est pas un motif connu → `no leaks found`. Le secret de `vuln-repo` est passé au format **jeton GitHub `ghp_…`** (détecté par les règles par défaut). Leçon documentée dans le script : un format maison exige une **règle personnalisée** (gitleaks.toml). |
| 24 | Ch30 Ex1 : retirer le secret du fichier ne suffit pas | gitleaks le retrouve dans **l'historique Git** (leçon du manuel). Le script démontre la purge : réinitialisation du dépôt de test (en réel : `git filter-repo`/`filter-branch` + révocation, ch. 13). |
| 25 | Ch30 Ex2 : `terraform validate` sur le montage `:ro` | `terraform init` ne peut pas écrire `.terraform/` sur un volume en lecture seule → validation IaC sur une **copie dans /tmp**. |
| 26 | Ch30 Ex2 : cosign signe vers le journal de transparence Rekor | En laboratoire, `sign-blob —tlog-upload=false` + `verify-blob —insecure-ignore-tlog` (pas de tlog, mode hors-ligne). |
| 27 | Ch17 Ex2 & Ch21 Ex1 : le manuel utilise `ufw` | `ufw` est un surcouche d'`iptables` ; dans un conteneur sans systemd, on applique la **même politique** directement en `iptables` (refuser entrant, autoriser 22/443, boucle locale, établi). Leçon identique, note lab. |
| 28 | Ch20 Ex2 : le manuel utilise `samba-tool` (annuaire AD) | Le lab n'embarque pas de contrôleur de domaine (lourd) → **transposition sur les comptes Linux** de vuln-host, même boucle : inventaire → comptes dormants (`lastlog`) → privilèges excessifs (`gpasswd -d`) → revérifier (moindre privilège). |
| 29 | Ch21 Ex2 : le manuel télécharge les règles ET (Emerging Threats) | Le réseau interne n'a **aucun egress** → suricata utilise des **règles locales** (SID 9000001-3 : HTTP, ICMP, SSH) pour des alertes déterministes. Image `jasonish/suricata` (AlmaLinux 9, `dnf`) ; volume anonyme `/etc/suricata` écrasé par un bind mount. |
| 30 | Ch25 Ex2 : le manuel décrit un assistant de test fictif | Le lab fournit `apps/llm-lab/assistant.py` (simulateur LLM) : mode `vulnerable` (concaténation naïve → fuite du secret) et mode `hardened` (séparation instruction/données + validation de sortie + moindre privilège). Démonstration, correction, re-test. |
| 31 | Ch20 Ex2 : `lastlog \| awk '$4 == "**" …'` ne détecte pas les comptes dormants | **Erreur réelle du manuel** : lastlog (Debian/Ubuntu, locale EN) affiche `svc_old ** ** **Never logged in**` → le champ 4 vaut `**Never`, pas `**` ; le motif ne matche jamais. Corrigé (fr+en, corps + exercice) : `lastlog \| grep -E "Never logged in\|Jamais" \| awk '{print $1}'`. |
| 32 | Ch19 Ex1 & Ch35 : `sha256sum "$DEST"/* > "$DEST/hashes.txt"` | **Erreur réelle du manuel** : le glob inclut `hashes.txt` lui-même (auto-référent → échec au 2ᵉ passage) et échoue sur un répertoire (Ch35 `incident/`). Corrigé (fr+en) : `find "$DEST" -type f ! -name hashes.txt -exec sha256sum {} + > "$DEST/hashes.txt"`. |
| 33 | Ch34 Ex1/Ex2 : le manuel utilise `logger` (syslog) et un SIEM | Le lab n'a pas de syslog/SIEM : la collecte est démontrée par un agent minimal (spool horodaté) et les règles par un auth.log simulé (même format Debian). La détection s'exécute sur la source (vuln-host). |
| 34 | Ch35 Ex2 : `ip link set eth1 down` et `strings` | Dans un conteneur, l'isolation est simulée par iptables DROP (INPUT/OUTPUT) — docker exec reste possible ; `strings` absent → `grep -a` sur le binaire. Un trap restaure le réseau en cas d'échec. |
| 35 | Ch31 Ex2 & Ch32 Ex2 : `date -u` (format par défaut) | La sortie `Wed Aug 12 07:11:03 UTC 2026` ne matche pas le motif ISO → `date -u +%Y-%m-%dT%H:%M:%SZ` pour la preuve horodatée. |
| 36 | Ch31 Ex3 : tunnel `ssh -N -f -L` dans `docker compose exec -T` | Le tunnel est **tué (SIGTERM, exit 143)** à la fin de la session exec (pas de TTY) → ouvrir le tunnel via **`docker compose exec -d`** (session détachée). De plus, `pkill -f "ssh -N.*18085"` **matche sa propre ligne de commande** (le motif est dans les args de bash -c) → pkill se tue lui-même avant `\|\| true` → motif `[s]sh` (astuce du crochet). |
| 37 | Ch36 Ex2 : `HITS=$(grep … \| wc -l \| tr -d ' ')` | Sous `set -euo pipefail`, `grep` sans correspondance sort en 1 → le pipeline échoue et le script meurt silencieusement → `\|\| true` sur les pipelines de comptage (le manuel reste correct : c'est une contrainte d'exécution du script de validation). |
| 38 | Examens blancs (Ch40-44) : corrigés vérifiés | **Aucune erreur factuelle** dans les 200 QCM ni dans les corrigés d'exercices (vérifiés dans le lab : `sha256sum`, `tar`, `ufw`, `hostname -I`, `ss -tulpn`, `curl -I` fonctionnent). Seule adaptation : `systemctl list-units` (Ch40 Ex2, Ch44 Ex2) est **absent des conteneurs sans systemd** → dans le lab, `ps -ef` + `ls /etc/init.d/` (même inventaire, cf. Ch38). Le manuel reste correct sur un serveur réel. |
