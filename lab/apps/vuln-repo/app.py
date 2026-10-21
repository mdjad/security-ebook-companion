#!/usr/bin/env python3
# ─────────────────────────────────────────────────────────────
#  VULN-REPO — dépôt volontairement vulnérable (Ch30 Ex1)
#
#  Contient volontairement :
#    - une requête SQL concaténée (injection SQL)
#    - une clé API en clair (config.py)
#  L'exercice consiste à les DÉTECTER (semgrep, gitleaks, trivy)
#  puis à les corriger. Ne jamais réutiliser ce code en production.
# ─────────────────────────────────────────────────────────────
import sqlite3

from config import API_KEY


def get_user(username):
    # ⚠ Vulnérabilité volontaire : concaténation SQL (injection)
    conn = sqlite3.connect("app.db")
    query = "SELECT * FROM users WHERE username = '" + username + "'"
    return conn.execute(query).fetchall()


def main():
    print("vuln-repo: application de test (Ch30)")
    print("clé API chargée:", API_KEY[:8] + "…")


if __name__ == "__main__":
    main()
