#!/bin/sh
# ─────────────────────────────────────────────────────────────
#  WEB-LAB — génère la config nginx selon SECURITY_HEADERS
#  off : aucun en-tête de sécurité (état vulnérable)
#  on  : HSTS + X-Content-Type-Options + CSP (état corrigé)
#  Les deux états exposent un serveur TLS auto-signé sur 443
#  (Ch12 Ex2 : audit TLS ; Ch33 : durcissement).
# ─────────────────────────────────────────────────────────────
set -e

if [ "$SECURITY_HEADERS" = "on" ]; then
  cat > /etc/nginx/conf.d/default.conf <<'EOF'
server {
    listen 80;
    server_name _;
    root /usr/share/nginx/html;
    index index.html;

    add_header Strict-Transport-Security "max-age=63072000" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Content-Security-Policy "default-src 'self'" always;
}

server {
    listen 443 ssl;
    server_name _;
    root /usr/share/nginx/html;
    index index.html;

    ssl_certificate     /etc/nginx/ssl/lab.crt;
    ssl_certificate_key /etc/nginx/ssl/lab.key;
    ssl_protocols       TLSv1.2 TLSv1.3;

    add_header Strict-Transport-Security "max-age=63072000" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Content-Security-Policy "default-src 'self'" always;
}
EOF
else
  cat > /etc/nginx/conf.d/default.conf <<'EOF'
server {
    listen 80;
    server_name _;
    root /usr/share/nginx/html;
    index index.html;
}

server {
    listen 443 ssl;
    server_name _;
    root /usr/share/nginx/html;
    index index.html;

    ssl_certificate     /etc/nginx/ssl/lab.crt;
    ssl_certificate_key /etc/nginx/ssl/lab.key;
    ssl_protocols       TLSv1.2 TLSv1.3;
}
EOF
fi

exec nginx -g "daemon off;"
