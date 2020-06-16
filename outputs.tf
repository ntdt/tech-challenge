output "ssh_connection_string" {
  value = "ssh -i ${local_file.ssh_key.filename} ec2-user@${module.ec2_instance.public_ip[0]}"
}

output "rsync_upload_cmd" {
  value = "eval $(ssh-agent) && ssh-add ${local_file.ssh_key.filename} && ./upload_files.sh ${var.worker_count} dataset/ ec2-user@${module.ec2_instance.public_ip[0]}:/mnt/dataset/"
}

output "rsync_download_cmd" {
  value = "eval $(ssh-agent) && ssh-add ${local_file.ssh_key.filename} && rsync -az ec2-user@${module.ec2_instance.public_ip[0]}:/mnt/result ."
}

output "update_kubeconfig" {
  value = "aws eks update-kubeconfig --region ${var.region} --name ${module.eks-cluster.cluster_id}"
}
