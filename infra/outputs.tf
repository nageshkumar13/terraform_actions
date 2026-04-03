output "instance_id" {
  description = "ID of the EC2 instance."
  value       = aws_instance.app_server.id
}

output "instance_public_ip" {
  description = "Elastic IP address attached to the EC2 instance."
  value       = aws_eip.app_server.public_ip
}

output "app_url" {
  description = "Browser URL for the deployed FastAPI application."
  value       = "http://${aws_eip.app_server.public_ip}:${var.host_port}"
}

output "security_group_id" {
  description = "ID of the security group attached to the instance."
  value       = aws_security_group.app_sg.id
}
