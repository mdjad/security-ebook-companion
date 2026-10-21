# ─────────────────────────────────────────────────────────────
#  WEB-LAB — Serveur web de test (Ch12 Ex2, Ch27)
#  nginx configurable : en-têtes de sécurité HSTS/CSP/nosniff
#  activables via la variable SECURITY_HEADERS (off | on).
#  Un serveur TLS auto-signé (443) est fourni pour l'audit TLS
#  (Ch12 Ex2) et le durcissement (Ch33).
# ─────────────────────────────────────────────────────────────
FROM nginx:1.27-alpine

# Certificat auto-signé de test (jamais pour la production)
RUN apk add --no-cache openssl \
    && mkdir -p /etc/nginx/ssl \
    && openssl req -x509 -nodes -newkey rsa:2048 -days 3650 \
       -keyout /etc/nginx/ssl/lab.key \
       -out /etc/nginx/ssl/lab.crt \
       -subj "/C=FR/ST=Lab/O=Security-Ebook-Lab/CN=web-lab" \
    && rm -rf /var/cache/apk/*

COPY index.html /usr/share/nginx/html/index.html
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 80 443
CMD ["/entrypoint.sh"]
