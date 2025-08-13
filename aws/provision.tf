# Run on mgmt and storage nodes

resource "null_resource" "provision_mgmt" {
  for_each = aws_instance.mgmt_node

  depends_on = [
    aws_instance.bastion,
    aws_instance.mgmt_node,
  ]

  connection {
    type        = "ssh"
    user        = var.ssh_user
    host        = each.value.private_ip
    private_key = file(var.ssh_private_key_path)

    bastion_host        = aws_instance.bastion[0].public_ip
    bastion_user        = var.ssh_user
    bastion_private_key = file(var.ssh_private_key_path)
  }

  # Create /tmp/scripts directory
  provisioner "remote-exec" {
    inline = [
      "mkdir -p /tmp/mgx-scripts"
    ]
  }

  provisioner "file" {
    source      = "../scripts"
    destination = "/tmp/mgx-scripts"
  }

  provisioner "remote-exec" {
    inline = [
      "cd /tmp/mgx-scripts/scripts",
      "chmod +x setup-mgmt.sh",
      "sudo ./setup-mgmt.sh"
    ]
  }
}

# Run on storage nodes
resource "null_resource" "provision_storage" {
  for_each = aws_instance.storage_node

  depends_on = [
    aws_instance.bastion,
    aws_instance.storage_node,
  ]

  connection {
    type        = "ssh"
    user        = var.ssh_user
    host        = each.value.private_ip
    private_key = file(var.ssh_private_key_path)

    bastion_host        = aws_instance.bastion[0].public_ip
    bastion_user        = var.ssh_user
    bastion_private_key = file(var.ssh_private_key_path)
  }

  # Create /tmp/scripts directory
  provisioner "remote-exec" {
    inline = [
      "mkdir -p /tmp/mgx-scripts"
    ]
  }

  provisioner "file" {
    source      = "../scripts"
    destination = "/tmp/mgx-scripts"
  }

  provisioner "remote-exec" {
    inline = [
      "cd /tmp/mgx-scripts/scripts",
      "chmod +x setup-storage.sh",
      "sudo ./setup-storage.sh"
    ]
  }
}
