output "server_name" {
    description = "The name of the server"
    value       = aws_instance.server.tags["Name"]
}

output "ip_address" {
    description = "The public IP address of the server"
    value       = aws_instance.server.public_ip
}

output "private_ip_address" {
    description = "The private IP address of the server"
    value       = aws_instance.server.private_ip
}