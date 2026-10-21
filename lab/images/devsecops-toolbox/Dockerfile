# ─────────────────────────────────────────────────────────────
#  DEVSECOPS-TOOLBOX — outils DevSecOps du laboratoire (Ch29-30)
#
#  Outils : trivy, grype, syft, semgrep, gitleaks, hadolint,
#          cosign, act, checkov, terraform, docker CLI.
#
#  NB : les outils installés via leur script officiel prennent la
#  version « latest » au moment du build (veille & évolution).
#  Pour épingler : remplacer par un téléchargement de release précis.
#
#  ⚠ docker.sock est monté depuis l'hôte (profil devsecops) :
#    accès root au daemon — labo uniquement, jamais en production.
# ─────────────────────────────────────────────────────────────
FROM debian:bookworm-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
         curl ca-certificates git make jq unzip \
         python3 python3-pip \
         docker.io \
    && rm -rf /var/lib/apt/lists/*

# Trivy — scanner de vulnérabilités (images + fichiers)
RUN curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh \
    | sh -s -- -b /usr/local/bin

# Grype (SCA) + Syft (SBOM)
RUN curl -sSfL https://raw.githubusercontent.com/anchore/grype/main/install.sh \
    | sh -s -- -b /usr/local/bin
RUN curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh \
    | sh -s -- -b /usr/local/bin

# Gitleaks — détection de secrets (tarball épinglé, arm64)
RUN curl -sSfL https://github.com/gitleaks/gitleaks/releases/download/v8.24.3/gitleaks_8.24.3_linux_arm64.tar.gz \
    -o /tmp/gitleaks.tgz \
    && tar -xzf /tmp/gitleaks.tgz -C /usr/local/bin gitleaks \
    && rm /tmp/gitleaks.tgz

# Hadolint — lint des Dockerfiles (binaire épinglé, arm64)
RUN curl -sSfL https://github.com/hadolint/hadolint/releases/download/v2.12.0/hadolint-Linux-arm64 \
    -o /usr/local/bin/hadolint \
    && chmod +x /usr/local/bin/hadolint

# Cosign — signature / vérification d'artefacts (binaire épinglé, arm64)
RUN curl -sSfL https://github.com/sigstore/cosign/releases/download/v2.4.3/cosign-linux-arm64 \
    -o /usr/local/bin/cosign \
    && chmod +x /usr/local/bin/cosign

# Act — exécution locale de workflows GitHub Actions
RUN curl -sSfL https://raw.githubusercontent.com/nektos/act/master/install.sh \
    | sh -s -- -b /usr/local/bin

# Semgrep (SAST) + Checkov (IaC)
# Debian bookworm = Python « externally managed » (PEP 668) → --break-system-packages
RUN pip install --no-cache-dir --break-system-packages semgrep checkov

# Terraform (version épinglée)
RUN curl -fsSL https://releases.hashicorp.com/terraform/1.9.8/terraform_1.9.8_linux_arm64.zip \
    -o /tmp/tf.zip \
    && unzip /tmp/tf.zip -d /usr/local/bin \
    && rm /tmp/tf.zip

RUN mkdir -p /lab/apps /lab/scripts /lab/datasets
WORKDIR /lab
CMD ["/bin/bash"]
