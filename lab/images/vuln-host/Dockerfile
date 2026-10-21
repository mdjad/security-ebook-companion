# ─────────────────────────────────────────────────────────────
#  VULN-HOST — cible hôte vulnérable du laboratoire
#
#  Services (équivalent « Metasploitable-like » en arm64) :
#    - OpenSSH  (identifiants faibles : admin/admin123, root/toor)
#    - vsftpd   (accès anonyme)
#    - nginx 1.22.1  (Debian bookworm)
#    - MariaDB  (base labo, utilisateur labo/labo123)
#    - binaire SUID anormal : /usr/local/bin/backup-helper (Ch16)
#
#  Testé : debian:bookworm (arm64), nginx 1.22.1, MariaDB 10.11
# ─────────────────────────────────────────────────────────────

# ── Stage build : compile le binaire SUID ─────────────────────
FROM debian:bookworm AS builder
RUN apt-get update \
    && apt-get install -y --no-install-recommends gcc libc6-dev \
    && rm -rf /var/lib/apt/lists/*
COPY helper.c /tmp/helper.c
RUN gcc -o /tmp/backup-helper /tmp/helper.c

# ── Stage runtime ─────────────────────────────────────────────
FROM debian:bookworm
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
         openssh-server vsftpd nginx mariadb-server \
         procps iproute2 net-tools curl \
         sudo login iptables ufw lynis \
    && rm -rf /var/lib/apt/lists/*

# Binaire SUID anormal (Ch16)
COPY --from=builder /tmp/backup-helper /usr/local/bin/backup-helper
RUN chmod 4755 /usr/local/bin/backup-helper

# Configuration vsftpd (accès anonyme)
COPY vsftpd.conf /etc/vsftpd.conf
RUN mkdir -p /var/run/vsftpd/empty /srv/ftp \
    && echo "Bienvenue sur le FTP du laboratoire" > /srv/ftp/README.txt

COPY init.sh /init.sh
RUN chmod +x /init.sh

EXPOSE 22 21 80 3306
CMD ["/init.sh"]
