output "public_ip" {
  description = "Public IP address"
  value       = aws_instance.minecraft.public_ip
}

output "instance_id" {
  value = aws_instance.minecraft.id
}
