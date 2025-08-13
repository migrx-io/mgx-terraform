output "bastion_public_ip" {
  description = "Public IP address of the bastion host"
  value       = length(aws_instance.bastion) > 0 ? aws_instance.bastion[0].public_ip : ""
}


output "mgmt_node_private_ips" {
  description = "Private IPs of the management nodes"
  value = [
    for ni in aws_network_interface.mgmt_primary :
    tolist(ni.private_ips)[0]
  ]
}

output "storage_node_mgmt_private_ips" {
  description = "Management IPs of the storage nodes"
  value = {
    for pool_name in keys(var.storage_pools) :
    pool_name => [
      for idx in range(var.storage_pools[pool_name].nodes_count) :
      tolist(aws_network_interface.storage_primary["${pool_name}-${idx}"].private_ips)[0]
    ]
  }
}

output "storage_node_data_private_ips" {
  description = "Data IPs of the storage nodes"
  value = {
    for pool_name in keys(var.storage_pools) :
    pool_name => [
      for idx in range(var.storage_pools[pool_name].nodes_count) :
      tolist(aws_network_interface.storage_secondary["${pool_name}-${idx}"].private_ips)[0]
    ]
  }
}
