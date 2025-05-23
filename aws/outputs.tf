output "bastion_public_ip" {
  description = "Public IP address of the bastion host"
  value       = aws_instance.bastion.public_ip
}

output "storage_node_private_ips" {
  description = "Private IPs of the storage nodes"
  value       = join("\n", [for instance in aws_instance.storage_node : instance.private_ip])
}
