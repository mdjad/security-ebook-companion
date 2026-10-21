# 🔬 Laboratoire du manuel — Cybersécurité à l'ère de l'IA

> **English version below** · *English version below*

Ce dossier contient un **environnement reproductible** pour une sélection d'exemples et
d'exercices du livre. Les scripts de validation vérifient les scénarios documentés dans le
laboratoire ; ils n'exécutent pas chaque commande ou exercice du manuel. Les corrections
identifiées en revue sont appliquées aux deux éditions (`fr/` + `en/`) lorsqu'elles sont pertinentes.

## ⚠️ Cadre éthique (non négociable)

- Ce laboratoire est **100 % local et isolé** : les cibles vulnérables sont sur un réseau
  interne **sans accès Internet** et **sans exposition sur le réseau local** (ports publiés
  uniquement sur `127.0.0.1`).
- Toutes les techniques offensives sont à pratiquer **uniquement ici** ou sur des systèmes
  pour lesquels vous disposez d'une **autorisation écrite** (cf. « Rappel légal » des chapitres).
- Tous les identifiants sont **fictifs** et destinés au laboratoire uniquement.

## Prérequis

- [Docker](https://www.docker.com/products/docker-desktop/) + Docker Compose (v2)
- Apple Silicon (arm64) ou x86_64 — les images sont multi-arch.

## Démarrage

```bash
cp .env.example .env          # une seule fois
make up                       # cibles + passerelle edge
```

| Profil | Commande | Services ajoutés |
|—-|—-|—-|
| *(défaut)* | `make up` | DVWA, Juice Shop, vuln-host, vuln-api, web-lab, suricata, edge |
| pentest | `make up-pentest` | + poste d'attaque Kali |
| web | `make up-web` | + scanner ZAP |
| devsecops | `make up-devsecops` | + outils DevSecOps + Vault |

## Accès depuis l'hôte (navigateur / curl)

Tous les ports sont liés à `127.0.0.1` (jamais exposés sur le LAN) :

| Service | URL | Description |
|—-|—-|—-|
| DVWA | http://127.0.0.1:18081 | application web vulnérable |
| Juice Shop | http://127.0.0.1:18082 | application web/API moderne vulnérable |
| vuln-api | http://127.0.0.1:18083 | API vulnérable (Ch27-28) |
| web-lab | http://127.0.0.1:18084 | serveur web de test (en-têtes, Ch27) |
| ZAP (profil web) | http://127.0.0.1:8090 | interface web du scanner |
| Vault (profil devsecops) | http://127.0.0.1:8200 | secrets (mode dev) |

## Poste d'attaque Kali

```bash
make up-pentest
make kali          # shell dans le conteneur Kali
```

Depuis Kali, les cibles sont joignables **par nom de conteneur** (le manuel utilise des IP
VirtualBox `10.77.0.x` ; dans le lab Docker, on utilise les noms) :

```bash
nmap -sV vuln-host
curl -s http://vuln-api/v1/items?limit=5 | jq .
hydra -l admin -P /lab/datasets/wordlist.txt ssh://vuln-host
```

## Organisation



## Règles du laboratoire

1. **Tout script publié dans le livre est exécuté ici** avant publication.
2. Chaque script indique en en-tête : chapitre, version testée, commande d'exécution, statut.
3. **Toute erreur du manuel** constatée → correction dans `fr/` **et** `en/`, journalisée dans
   `VALIDATION.md`.
4. Les données sensibles ne sont jamais publiées : le laboratoire n'utilise que des données fictives.

## Validation

```bash
make validate          # exécute tous les scripts de validation
make validate-11       # valide une partie précise (ex. Partie 11 : examens blancs)
```

## Arrêt et nettoyage

```bash
make down              # arrête sans supprimer les données
make reset             # arrête ET supprime les volumes + rebuild complet
```

—-

# 🔬 Book Lab — Cybersecurity in the Age of AI

This folder contains a **reproducible environment** for selected examples and exercises in the
book. The validation scripts check documented workflows in the lab; they do not execute every
command or exercise in the manual. Corrections identified during review are applied to both
editions (`fr/` + `en/`) when relevant.

## ⚠️ Ethical framework (non-negotiable)

- This lab is **100% local and isolated**: vulnerable targets sit on an internal network with
  **no Internet access** and **no LAN exposure** (published ports bound to `127.0.0.1` only).
- All offensive techniques must be practiced **only here** or on systems you are **authorized in
  writing** to test (see the "Legal reminder" boxes in the chapters).
- All credentials are **fictitious** and lab-only.

## Quick start

```bash
cp .env.example .env          # once
make up                       # targets + edge gateway
```

| Profile | Command | Added services |
|—-|—-|—-|
| *(default)* | `make up` | DVWA, Juice Shop, vuln-host, vuln-api, web-lab, suricata, edge |
| pentest | `make up-pentest` | + Kali attack box |
| web | `make up-web` | + ZAP scanner |
| devsecops | `make up-devsecops` | + DevSecOps tools + Vault |

## Host access (browser / curl)

All ports are bound to `127.0.0.1` (never exposed on the LAN):

| Service | URL | Description |
|—-|—-|—-|
| DVWA | http://127.0.0.1:18081 | vulnerable web app |
| Juice Shop | http://127.0.0.1:18082 | modern vulnerable web/API app |
| vuln-api | http://127.0.0.1:18083 | vulnerable API (Ch27-28) |
| web-lab | http://127.0.0.1:18084 | test web server (headers, Ch27) |
| ZAP (web profile) | http://127.0.0.1:8090 | scanner web UI |
| Vault (devsecops profile) | http://127.0.0.1:8200 | secrets (dev mode) |

## Kali attack box

```bash
make up-pentest
make kali          # shell into the Kali container
```

From Kali, targets are reachable **by container name** (the book uses VirtualBox IPs
`10.77.0.x`; in the Docker lab we use names):

```bash
nmap -sV vuln-host
curl -s http://vuln-api/v1/items?limit=5 | jq .
hydra -l admin -P /lab/datasets/wordlist.txt ssh://vuln-host
```

## Lab rules

1. Scripts in this repository support reproducing selected examples; consult their headers for scope and version notes.
2. Each script header states: chapter, tested version, execution command, status.
3. **Any book error** found → corrected in `fr/` **and** `en/`, logged in `VALIDATION.md`.
4. Sensitive data is never published: the lab only uses fictitious data.

## Validation

```bash
make validate          # run all validation scripts
make validate-11       # validate one part (e.g. Part 11: mock exams)
```

## Stop and cleanup

```bash
make down              # stop without deleting data
make reset             # stop AND delete volumes + full rebuild
```
