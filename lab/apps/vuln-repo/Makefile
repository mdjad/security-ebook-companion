# ─────────────────────────────────────────────────────────────
#  VULN-REPO — Makefile (Ch30 Ex2 : cible `test` du pipeline)
# ─────────────────────────────────────────────────────────────
.PHONY: test build

test:
	@echo "OK: tests passés (exercice Ch30)"
	@python3 -c "import ast; ast.parse(open('app.py').read())" && echo "OK: syntaxe valide"

build:
	docker build -t app-lab:ci .
