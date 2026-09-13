terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Generare automată pereche de chei RSA de 4096 biți
resource "tls_private_key" "devops_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Declarare SSH Key Pair în AWS folosind cheia publică generată
resource "aws_key_pair" "generated_key" {
  key_name   = "envbuilder-key"
  public_key = tls_private_key.devops_key.public_key_openssh
}

# Salvarea cheii private pe disc cu permisiuni de securitate (0600) pentru Ansible/SSH
resource "local_file" "private_key" {
  content         = tls_private_key.devops_key.private_key_pem
  filename        = "${path.module}/envbuilder-key.pem"
  file_permission = "0600"
}

# Security Group: Filtrare trafic de rețea
resource "aws_security_group" "envbuilder_sg" {
  name        = "envbuilder-security-group"
  description = "Permite acces SSH si Web"

  # Regulă de Ingress: Acces SSH pe portul 22
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Regulă de Ingress: Acces HTTP pe portul 80
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Regulă de Egress: Permite tot traficul de ieșire
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Interogare dinamică pentru cel mai recent AMI Ubuntu 22.04 LTS
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

# Provizionare instanță EC2 în AWS
resource "aws_instance" "envbuilder_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  key_name               = aws_key_pair.generated_key.key_name
  vpc_security_group_ids = [aws_security_group.envbuilder_sg.id]

  tags = {
    Name = "DevOps-EnvBuilder-Server"
  }
}

# Output: IP-ul public necesar conectării ulterioare
output "public_ip" {
  description = "IP-ul public al serverului EC2"
  value       = aws_instance.envbuilder_server.public_ip
}