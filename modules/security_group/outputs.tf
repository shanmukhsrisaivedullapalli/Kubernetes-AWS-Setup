output "sg_name" {
  description = "Security Group Name"
  value = aws_security_group.kubernetes_sg
}

output "sg_id" {
  description = "Security Group ID"
  value = aws_security_group.kubernetes_sg.id
}