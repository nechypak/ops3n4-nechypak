variable "aws_region" {
  description = "AWS region used for Ops 3 resources."
  type        = string
  default     = "us-east-1"
}

variable "availability_zone" {
  description = "Availability zone for the public subnet."
  type        = string
  default     = "us-east-1a"
}

variable "onid" {
  description = "ONID or GitHub username used for naming and tags."
  type        = string
  default     = "nechypak"
}

variable "key_name" {
  description = "Existing AWS EC2 key pair name."
  type        = string
}

variable "admin_ssh_cidr" {
  description = "CIDR allowed to SSH into the Minecraft EC2 instance from the Ansible control node. For local Mac control node, use your public IP with /32."
  type        = string
  default     = "0.0.0.0/0"
}

variable "minecraft_client_cidr" {
  description = "CIDR allowed to connect to Minecraft TCP 25565."
  type        = string
  default     = "0.0.0.0/0"
}

variable "minecraft_instance_type" {
  description = "EC2 instance type for the Minecraft managed node."
  type        = string
  default     = "t3.medium"
}

variable "minecraft_root_volume_gib" {
  description = "Root EBS volume size for the Minecraft server in GiB."
  type        = number
  default     = 20
}

variable "ecr_repository_name" {
  description = "ECR repository name for the Minecraft image."
  type        = string
  default     = "ops3-minecraft-lab"
}

variable "minecraft_image_tag" {
  description = "Pinned Minecraft image tag used by Ansible and documentation."
  type        = string
  default     = "mc-java21-v1"
}

variable "backup_bucket_name" {
  description = "S3 bucket for Minecraft world backups. Must be globally unique."
  type        = string
  default     = "ops3-nechypak-minecraft-backups"
}

variable "backup_retention_days" {
  description = "Number of days to keep old world backups in S3."
  type        = number
  default     = 7
}