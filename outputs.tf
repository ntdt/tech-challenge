output "ssh_connection_string" {
  value = "ssh -i ${local_file.ssh_key.filename} ec2-user@${module.ec2_instance.public_ip[0]}"
}
