# ─────────────────────────────────────────────────────────────
#  LABORATOIRE DU MANUEL — Cybersécurité à l'ère de l'IA
#
#  Commandes courtes pour piloter l'environnement Docker.
#  Usage :  make <cible>   (depuis lab/)
# ─────────────────────────────────────────────────────────────

SHELL := /bin/bash
COMPOSE := docker compose

.PHONY: help up up-pentest up-web up-devsecops down reset \
        kali zap devsecops build \
        validate validate-02 validate-03 validate-04 validate-05 \
        validate-06 validate-07 validate-08 validate-09 validate-10 validate-11

help:
	@echo "Cibles disponibles :"
	@echo "  make up              → cibles + passerelle edge (défaut)"
	@echo "  make up-pentest      → + poste d'attaque Kali"
	@echo "  make up-web          → + scanner ZAP"
	@echo "  make up-devsecops    → + outils DevSecOps + Vault"
	@echo "  make down            → arrêt (sans supprimer les volumes)"
	@echo "  make reset           → arrêt + suppression volumes + rebuild complet"
	@echo "  make kali            → shell dans le conteneur Kali"
	@echo "  make zap             → shell dans le conteneur ZAP"
	@echo "  make devsecops       → shell dans le conteneur DevSecOps"
	@echo "  make validate        → exécute tous les scripts de validation"
	@echo "  make validate-02/03/04/05/06/07/08/09/10/11 → valide une partie précise"

up:            ; $(COMPOSE) up -d
up-pentest:    ; $(COMPOSE) --profile pentest up -d
up-web:        ; $(COMPOSE) --profile web up -d
up-devsecops:  ; $(COMPOSE) --profile devsecops up -d
down:          ; $(COMPOSE) down --remove-orphans
reset:         ; $(COMPOSE) down -v --remove-orphans && $(COMPOSE) build --pull \
                 && $(COMPOSE) --profile pentest --profile web --profile devsecops up -d --build

kali:          ; $(COMPOSE) --profile pentest exec kali bash
zap:           ; $(COMPOSE) --profile web exec zap bash
devsecops:     ; $(COMPOSE) --profile devsecops exec devsecops-toolbox bash

build:         ; $(COMPOSE) build

validate: up-pentest up-web up-devsecops
	@for d in scripts/0[2-9]-*/ scripts/10-*/ scripts/11-*/; do \
		if [ -f "$$d/validate.sh" ]; then \
			echo "== $$d"; bash "$$d/validate.sh" || exit 1; \
		fi; \
	done
	@echo "✅ Toutes les parties validées."

validate-02:   ; bash scripts/02-socle-technique/validate.sh
validate-03:   ; bash scripts/03-boite-a-outils/validate.sh
validate-04:   ; bash scripts/04-crypto-secrets/validate.sh
validate-05:   ; bash scripts/05-pentest/validate.sh
validate-06:   ; bash scripts/06-defense-soc/validate.sh
validate-07:   ; bash scripts/07-ia-cybersecurite/validate.sh
validate-08:   ; bash scripts/08-web-cloud-devsecops/validate.sh
validate-09:   ; bash scripts/09-cas-pratiques/validate.sh
validate-10:   ; bash scripts/10-erreurs-commandes-memo/validate.sh
validate-11:   ; bash scripts/11-examens-blancs/validate.sh
