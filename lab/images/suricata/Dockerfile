# ─────────────────────────────────────────────────────────────
#  SURICATA — IDS du laboratoire (Ch21 Ex2)
#
#  Base : jasonish/suricata (multi-arch, arm64 OK, Suricata 8.x,
#  AlmaLinux 9). On ajoute ping (iputils) et netcat (nmap-ncat)
#  pour générer le trafic de test (ICMP + connexion SSH) depuis le
#  conteneur, comme le fait le manuel (« depuis la même machine »).
#
#  Règles : local.rules maison (SIDs 9000001-9000003) → alertes
#  déterministes (HTTP, ICMP, SSH) sans dépendre d'un téléchargement
#  de règles ET (réseau interne sans Internet).
# ─────────────────────────────────────────────────────────────
FROM jasonish/suricata:latest

RUN dnf install -y iputils nmap-ncat \
    && dnf clean all

COPY local.rules /etc/suricata/local.rules

CMD ["tail", "-f", "/dev/null"]
