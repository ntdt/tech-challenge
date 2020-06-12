provider "kubernetes" {}

resource "local_file" "pv" {
  content         = templatefile("${path.module}/templates/pv.yaml", { EFS_ID = module.efs.id })
  filename        = "${path.module}/specs/pv.yaml"
  file_permission = "0644"
}

resource "local_file" "jobs" {
  content         = templatefile("${path.module}/templates/jobs.yaml", { WORKER_COUNT = var.worker_count })
  filename        = "${path.module}/specs/jobs.yaml"
  file_permission = "0644"
}
