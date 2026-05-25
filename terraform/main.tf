terraform {
  required_version = ">= 1.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Ubuntu Server 24.04 LTS
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

locals {
  common_tags = {
    Owner      = var.onid
    Course     = "CS312"
    Assignment = "Ops3"
  }
}

resource "aws_vpc" "ops3" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(local.common_tags, {
    Name = "ops3-vpc-${var.onid}"
  })
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.ops3.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, {
    Name = "ops3-public-subnet-${var.onid}"
  })
}

resource "aws_internet_gateway" "ops3" {
  vpc_id = aws_vpc.ops3.id

  tags = merge(local.common_tags, {
    Name = "ops3-igw-${var.onid}"
  })
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.ops3.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ops3.id
  }

  tags = merge(local.common_tags, {
    Name = "ops3-public-rt-${var.onid}"
  })
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}


resource "aws_security_group" "minecraft" {
  name        = "ops3-minecraft-sg-${var.onid}"
  description = "Ops3 Minecraft server: SSH from admin CIDR, Minecraft TCP public"
  vpc_id      = aws_vpc.ops3.id

  ingress {
    description = "SSH from admin laptop / control node"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.admin_ssh_cidr]
  }

  ingress {
    description = "Minecraft TCP 25565"
    from_port   = 25565
    to_port     = 25565
    protocol    = "tcp"
    cidr_blocks = [var.minecraft_client_cidr]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "ops3-minecraft-sg-${var.onid}"
  })
}

resource "aws_instance" "minecraft" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.minecraft_instance_type
  key_name               = var.key_name
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.minecraft.id]

  iam_instance_profile = "LabInstanceProfile"

  root_block_device {
    volume_size = var.minecraft_root_volume_gib
    volume_type = "gp3"
  }

  tags = merge(local.common_tags, {
    Name = "ops3-minecraft-${var.onid}"
    Role = "minecraft-server"
  })
}

resource "aws_ecr_repository" "minecraft" {
  name                 = var.ecr_repository_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge(local.common_tags, {
    Name = var.ecr_repository_name
  })
}

resource "aws_s3_bucket" "minecraft_backups" {
  bucket = var.backup_bucket_name

  tags = merge(local.common_tags, {
    Name = var.backup_bucket_name
  })
}

resource "aws_s3_bucket_public_access_block" "minecraft_backups" {
  bucket = aws_s3_bucket.minecraft_backups.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "minecraft_backups" {
  bucket = aws_s3_bucket.minecraft_backups.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "minecraft_backups" {
  bucket = aws_s3_bucket.minecraft_backups.id

  rule {
    id     = "expire-old-world-backups"
    status = "Enabled"

    filter {
      prefix = "world-backups/"
    }

    expiration {
      days = var.backup_retention_days
    }
  }
}