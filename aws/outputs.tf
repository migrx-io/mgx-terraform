output "bastion_public_ip" {
  description = "Public IP address of the bastion host"
  value       = length(aws_instance.bastion) > 0 ? aws_instance.bastion[0].public_ip : ""
}


output "storage_node_private_ips" {
  description = "Private IPs of the storage nodes grouped by pool"
  value = {
    for pool_name in keys(var.storage_pools) :
    pool_name => [
      for instance_key, instance in aws_instance.storage_node :
      instance.private_ip if startswith(instance_key, "${pool_name}-")
    ]
  }
}
