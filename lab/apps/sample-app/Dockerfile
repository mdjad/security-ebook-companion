# ─────────────────────────────────────────────────────────────
#  SAMPLE-APP — Dockerfile de l'exercice Ch29 (durcissement)
#  Reprend exactement l'exemple du chapitre :
#    - base python:3.12-slim
#    - curl installé (--no-install-recommends)
#    - utilisateur non-root `app`
#    - COPY --chown=app:app
#    - EXPOSE 8000
# ─────────────────────────────────────────────────────────────
FROM python:3.12-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends curl \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -r -m app

WORKDIR /app
COPY --chown=app:app . /app

USER app
EXPOSE 8000
CMD ["python", "app.py"]
