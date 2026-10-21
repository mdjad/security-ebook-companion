# Laboratoire compagnon — Cybersécurité à l’ère de l’IA

Ce dépôt fournit le laboratoire Docker associé au manuel **Cybersécurité à l’ère de l’intelligence artificielle**. Il rassemble l’environnement, les cibles de démonstration, les jeux de données fictifs et les scripts de validation, séparément des sources éditoriales du livre.

## Démarrage rapide

Prérequis : Docker Engine et Docker Compose v2.

```bash
git clone https://github.com/mdjad/security-ebook-companion.git
cd security-ebook-companion/lab
cp .env.example .env
make up
```

Le profil par défaut démarre les cibles et la passerelle du laboratoire. Les profils `pentest`, `web` et `devsecops` ajoutent les outils associés :

```bash
make up-pentest
make up-web
make up-devsecops
```

Les commandes de validation et les consignes d’accès figurent dans [`lab/README.md`](lab/README.md). Le journal des vérifications et des limites connues est dans [`lab/VALIDATION.md`](lab/VALIDATION.md).

## Cadre d’utilisation

Ce laboratoire est destiné à l’apprentissage local. Les cibles vulnérables sont isolées sur un réseau interne et les ports publiés sont liés à `127.0.0.1`. Les identifiants et jeux de données sont fictifs. Ne dirigez jamais les outils du laboratoire vers des systèmes tiers : toute activité offensive doit rester dans cet environnement ou disposer d’une autorisation écrite et d’un périmètre défini.

Le manuel ne prétend pas que chaque commande ou exercice a été exécuté sur toutes les plateformes. Consultez les notes de validation des scripts avant de reproduire un scénario.

## Contenu

- `lab/docker-compose.yml` et `lab/Makefile` : environnement et commandes de gestion.
- `lab/images/` et `lab/apps/` : conteneurs et applications de démonstration.
- `lab/scripts/` : scénarios de validation classés par partie du livre.
- `lab/datasets/` : jeux de données fictifs pour les exercices.
- `lab/VALIDATION.md` : résultats de validation et écarts documentés.

Les sources du manuel et les éditions française et anglaise sont publiées dans le dépôt [`security-ebook`](https://github.com/mdjad/security-ebook).
