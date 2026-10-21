# ─────────────────────────────────────────────────────────────
#  VULN-API — API vulnérable du laboratoire (Ch27-28)
#  Base : python:3.12-slim (multi-arch, arm64 OK)
#  Testé : python 3.12, Flask 3.x
# ─────────────────────────────────────────────────────────────
FROM python:3.12-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r /app/requirements.txt
COPY app.py /app/app.py

EXPOSE 5000
CMD ["python", "app.py"]
