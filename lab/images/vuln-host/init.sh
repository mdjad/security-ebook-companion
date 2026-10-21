#!/bin/bash
# ─────────────────────────────────────────────────────────────
#  VULN-HOST — démarre tous les services de la cible
#  (sshd, vsftpd, nginx, mariadb) puis garde le conteneur vivant.
# ─────────────────────────────────────────────────────────────
set -e

echo "[vuln-host] démarrage des services..."

# 1) Clés SSH hôte
ssh-keygen -A

# 2) Identifiants faibles (fictifs, labo uniquement)
useradd -m -s /bin/bash admin 2>/dev/null || true
echo 'admin:admin123' | chpasswd
echo 'root:toor' | chpasswd

# Compte « suspect » (Ch06 Ex2) : présent sur la machine mais absent
# de la liste officielle (datasets/liste_officielle.txt)
useradd -m -s /bin/bash svc_backup 2>/dev/null || true
echo 'svc_backup:backup123' | chpasswd

# 3) MariaDB
# La cible est « vulnérable » : la base écoute sur toutes les
# interfaces (le manuel la suppose joignable depuis le poste d'attaque).
sed -i 's/^bind-address.*/bind-address = 0.0.0.0/' /etc/mysql/mariadb.conf.d/50-server.cnf
mkdir -p /run/mysqld && chown mysql:mysql /run/mysqld
mysqld_safe --skip-networking=0 >/var/log/mysqld.log 2>&1 &
for i in $(seq 1 30); do
  mysqladmin ping --silent 2>/dev/null && break
  sleep 1
done
mysql -uroot <<'SQL'
CREATE DATABASE IF NOT EXISTS labo;
CREATE USER IF NOT EXISTS 'labo'@'%' IDENTIFIED BY 'labo123';
GRANT ALL PRIVILEGES ON labo.* TO 'labo'@'%';
FLUSH PRIVILEGES;
SQL

# 4) vsftpd (accès anonyme)
/usr/sbin/vsftpd /etc/vsftpd.conf >/var/log/vsftpd.log 2>&1 &

# 5) nginx
/usr/sbin/nginx

# 6) sshd
mkdir -p /run/sshd
/usr/sbin/sshd

echo "[vuln-host] services prêts : ssh(22) ftp(21) http(80) mysql(3306)"
tail -f /dev/null
