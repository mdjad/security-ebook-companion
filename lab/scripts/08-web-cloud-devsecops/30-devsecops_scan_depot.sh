#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  Chapitre  : 30 — DevSecOps : sécuriser la chaîne CI/CD
#  Exercice  : 1 (Débutant) — Scanner un petit dépôt en local
#  Version   : devsecops-toolbox (semgrep 1.172.0, gitleaks 8.24.3, trivy 0.73.0)
#  Exécution : bash scripts/08-web-cloud-devsecops/30-devsecops_scan_depot.sh
#              (depuis lab/ ; nécessite `make up-devsecops`)
#  Statut    : VALIDÉ (2026-08-12)
#
#  Adaptation Docker : `vuln-repo` est monté en lecture seule et fourni
#  sans historique git (le `.git` imbriqué n'est pas commité). L'exercice
#  exige que le secret soit dans l'HISTORIQUE (gitleaks scanne les commits)
#  → le script travaille sur une copie /tmp, y bootstrap l'historique
#  (secret commité), puis déroule la boucle DevSecOps : mesurer → corriger
#  → recontrôler, et termine par la purge de l'historique.
#
#  Leçon démontrée : retirer un secret du fichier ne suffit PAS — il
#  reste dans l'historique Git (gitleaks le retrouve). Il faut purger
#  l'historique (ici : réinitialisation du dépôt de test ; en réel :
#  git filter-repo / filter-branch, puis révocation, ch. 13).
# ─────────────────────────────────────────────────────────────
set -euo pipefail
cd "$(dirname "$0")/../.."   # → lab/

echo "== Ch30 Ex1 — Scan d'un dépôt (SAST + secrets + SCA) =="
fail=0

out=$(docker compose exec -T devsecops-toolbox bash -c '
set -e
# 0. Copie de travail dans /tmp (montage en lecture seule) + bootstrap git
rm -rf /tmp/vuln-repo && cp -r /lab/apps/vuln-repo /tmp/vuln-repo
cd /tmp/vuln-repo
git init -q
git add -A
git -c user.name="Lab" -c user.email="lab@test.local" commit -q -m "vuln-repo: dépôt de test volontairement vulnérable (Ch30)"

# 1. SAST (semgrep)
echo "--- semgrep (SAST) ---"
semgrep --config auto --quiet --json . 2>/dev/null | python3 -c "import json,sys; d=json.load(sys.stdin); print(\"constats:\", len(d.get(\"results\",[])))"

# 2. Secrets (gitleaks, historique inclus)
echo "--- gitleaks (secrets) ---"
gitleaks detect --source . --no-banner --redact 2>&1 | grep -E "leaks found: [1-9]" || echo "0 leak"

# 3. SCA (trivy fs)
echo "--- trivy fs (SCA) ---"
trivy fs --severity HIGH,CRITICAL --no-progress . 2>/dev/null | grep -cE "CVE-" | sed "s/^/CVE count: /"

# 4. Correction : requête paramétrée + secret retiré du fichier
python3 - <<PYEOF
import re
# app.py : requête paramétrée (fini la concaténation SQL)
src = open("app.py").read()
old = """    query = \"SELECT * FROM users WHERE username = \x27\" + username + \"\x27\"
    return conn.execute(query).fetchall()"""
new = """    query = \"SELECT * FROM users WHERE username = ?\"
    return conn.execute(query, (username,)).fetchall()"""
assert old in src, "motif SQL non trouvé"
open("app.py", "w").write(src.replace(old, new))
# config.py : secret retiré du fichier (déplacé vers une variable gérée, ch. 13)
cfg = open("config.py").read()
cfg = re.sub(r"API_KEY = \"[^\"]*\"", "API_KEY = os.environ.get(\"API_KEY\", \"\")", cfg)
if "import os" not in cfg:
    cfg = "import os\n" + cfg
open("config.py", "w").write(cfg)
PYEOF

# 5. Re-vérification : le constat SQL est corrigé, MAIS le secret
#    reste dans l historique Git (leçon : purger l historique)
echo "--- re-vérification (copie corrigée, avant purge) ---"
semgrep --config auto --quiet --json . 2>/dev/null | python3 -c "import json,sys; d=json.load(sys.stdin); r=d.get(\"results\",[]); print(\"constats restants:\", len(r)); print(\"app.py encore signalé:\", any(x[\"path\"].endswith(\"app.py\") for x in r))"
gitleaks detect --source . --no-banner --redact 2>&1 | grep -E "leaks found: [1-9]" || echo "0 leak"

# 6. Purge de l historique (dépôt de test : réinitialisation ; en réel :
#    git filter-repo / filter-branch, puis révocation de la clé)
echo "--- purge de l historique ---"
rm -rf .git && git init -q && git add -A && git -c user.name="Lab" -c user.email="lab@test.local" commit -q -m "dépôt purgé (secret retiré)"

# 7. Re-vérification finale : plus aucun secret
echo "--- re-vérification (après purge) ---"
gitleaks detect --source . --no-banner --redact 2>&1 | grep -E "leaks found: [1-9]" || echo "0 leak"
')
echo "$out"

echo
echo "--- Vérifications ---"
echo "$out" | grep -q "constats: 3" && echo "✓ semgrep : 3 constats détectés (injection SQL, Dockerfile, workflow)" || { echo "✗ semgrep : nombre de constats inattendu"; fail=1; }
echo "$out" | grep -q "leaks found: 1" && echo "✓ gitleaks : secret détecté (jeton ghp_)" || { echo "✗ gitleaks : secret non détecté"; fail=1; }
echo "$out" | grep -q "app.py encore signalé: False" && echo "✓ semgrep : injection SQL corrigée (requête paramétrée)" || { echo "✗ semgrep : app.py encore signalé"; fail=1; }
echo "$out" | grep -q "leaks found: 1" && echo "✓ leçon : le secret reste dans l'historique après retrait du fichier" || { echo "✗ leçon non démontrée"; fail=1; }
echo "$out" | grep -q "0 leak" && echo "✓ gitleaks : plus aucun secret après purge de l'historique" || { echo "✗ secret encore présent après purge"; fail=1; }

echo
if [ "$fail" -eq 0 ]; then
  echo "✅ Ch30 Ex1 : VALIDÉ"
else
  echo "❌ Ch30 Ex1 : ÉCHEC"
  exit 1
fi
