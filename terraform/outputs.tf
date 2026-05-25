output "minecraft_node_public_ip" {
  description = "Public IP of the Minecraft server."
  value       = aws_instance.minecraft.public_ip
}

output "minecraft_node_private_ip" {
  description = "Private IP of the Minecraft server."
  value       = aws_instance.minecraft.private_ip
}

output "minecraft_public_endpoint" {
  description = "Public endpoint for Minecraft clients and nmap."
  value       = "${aws_instance.minecraft.public_ip}:25565"
}

output "ssh_command" {
  description = "SSH command from local Mac control node to the Minecraft EC2 instance."
  value       = "ssh -i ~/Downloads/${var.key_name}.pem ubuntu@${aws_instance.minecraft.public_ip}"
}

output "ansible_inventory_line" {
  description = "Inventory line for Ansible from local Mac control node."
  value       = "minecraft ansible_host=${aws_instance.minecraft.public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=~/Downloads/${var.key_name}.pem"
}

output "ecr_repository_url" {
  description = "ECR repository URL."
  value       = aws_ecr_repository.minecraft.repository_url
}

output "backup_bucket_name" {
  description = "S3 bucket for Minecraft world backups."
  value       = aws_s3_bucket.minecraft_backups.bucket
}

output "vpc_id" {
  description = "VPC ID."
  value       = aws_vpc.ops3.id
}

output "minecraft_security_group_id" {
  description = "Security group ID for the Minecraft node."
  value       = aws_security_group.minecraft.id
}