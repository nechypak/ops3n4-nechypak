terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

data "aws_vpc" "default" {
  default = true
}

resource "aws_instance" "minecraft" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.managed.id]
  associate_public_ip_address = true

  iam_instance_profile   = "LabInstanceProfile"

  tags = {
    Name = "ops4-nechypak"
  }
}

resource "local_file" "inventory" {
  filename = "${path.module}/inventory"
  content  = <<EOF
[minecraft]
minecraft-server ansible_host=${aws_instance.minecraft.public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=~/Downloads/cs312-key.pem
EOF
}

resource "aws_security_group" "managed" {
  name        = "ops4-managed-nechypak-sg"
  description = "Managed node: SSH from control node"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description     = "SSH from control node"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  ingress {
    description = "Minecraft"
    from_port   = 25565
    to_port     = 25565
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ops4-managed-nechypak-sg"
  }
}

resource "null_resource" "run_script" {
  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command = <<EOF
sleep 60
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ${path.module}/inventory ${path.module}/../ansible/configure-minecraft.yml
EOF
  }
}