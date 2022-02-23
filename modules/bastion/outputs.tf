output "bastion_subnet_id" {
  description = "the id of the bastion subnet"
  value       = aws_subnet.bastion_subnet.id
}