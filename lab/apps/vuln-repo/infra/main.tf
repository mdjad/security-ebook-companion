# ─────────────────────────────────────────────────────────────
#  VULN-REPO — infrastructure volontairement vulnérable (Ch30)
#  ⚠ Groupe de sécurité ouvert à tous (0.0.0.0/0) : à détecter
#  avec checkov. Ne jamais déployer cette configuration.
# ─────────────────────────────────────────────────────────────
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

resource "aws_security_group" "web" {
  name        = "web-sg"
  description = "Groupe de sécurité volontairement permissif (labo)"

  # ⚠ Vulnérabilité volontaire : SSH ouvert à tous
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # ⚠ Vulnérabilité volontaire : MySQL (3306) exposé
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
