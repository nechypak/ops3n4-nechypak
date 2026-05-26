output "managed_node_public_ip" {
  description = "Public IP of the control node: SSH here from your laptop"
  value = aws_instance.minecraft.public_ip
}