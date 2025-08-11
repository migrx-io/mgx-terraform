# Run on mgmt nodes
resource "null_resource" "provision_mgmt" {
  for_each = aws_instance.mgmt_node

  depends_on = [
    aws_instance.bastion,
    aws_instance.mgmt_node
  ]

  connection {
    type                = "ssh"
    user                = var.ssh_user
    host                = each.value.private_ip
    private_key         = file(var.ssh_private_key_path)

    bastion_host        = aws_instance.bastion[0].public_ip
    bastion_user        = var.ssh_user
    bastion_private_key = file(var.ssh_private_key_path)
  }

  provisioner "file" {
    source      = "scripts/setup-mgmt.sh"
    destination = "/tmp/setup-mgmt.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/setup-mgmt.sh",
      "sudo /tmp/setup-mgmt.sh"
    ]
  }
}

# Run on storage nodes
resource "null_resource" "provision_storage" {
  for_each = aws_instance.storage_node

  depends_on = [
    aws_instance.bastion,
    aws_instance.storage_node
  ]

  connection {
    type                = "ssh"
    user                = var.ssh_user
    host                = each.value.private_ip
    private_key         = file(var.ssh_private_key_path)

    bastion_host        = aws_instance.bastion[0].public_ip
    bastion_user        = var.ssh_user
    bastion_private_key = file(var.ssh_private_key_path)
  }

  provisioner "file" {
    source      = "scripts/setup-storage.sh"
    destination = "/tmp/setup-storage.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/setup-storage.sh",
      "sudo /tmp/setup-storage.sh"
    ]
  }
}
