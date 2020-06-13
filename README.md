# Parallel jobs to process images

This is a system that provision needed infrastructure and launch jobs parallelly to process images.
In order to speed up the process, many workers are used and the dataset of images need to be divided to equal part for each worker. The filesystem choosen need to be shared to each worker and it should provide a way for user interaction.

## Analyse and technologies

- EKS to launch k8s Jobs

- EFS is used to share the dataset of images to Jobs

- An EC2 instance with SSH access is used to provide the interaction with users for upload dataset and download results.

- Terraform to provision AWS resources: EC2, EKS, EFS, VPC

- Terraform to provision SSH access, k8s manifest templating

- Shell scripts to prepare dataset and divide it to equal parts for each worker

- Makefile to simplify the commands

- Prometheus for metrics and monitoring

## Parameters

Edit `terraform.tfvars` to specify the number of `worker_count`, `region` and `vpc_cidr`

## Use make for tasks:

- `make build`: build docker image and push to docker hub

- `make init`: initialize terraform

- `make plan`: terraform plan

- `make apply`: terraform apply

- `make upload`: upload images to filestore EC2 instance

- `make install_csi`: Install AWS EFS CSI driver for k8s cluster

- `make run`: launch Jobs to process images

- `make download`: download images processed to *result*

- `make prepare_prometheus` then `make prometheus` to install Prometheus to ingest metrics from k8s cluster

- `make dashboard` install k8s dashboard

- `make logging` create the logging stack with EFK

## Access to Prometheus

Use kubectl to port forward the Prometheus console to your local machine.

`kubectl --namespace=prometheus port-forward deploy/prometheus-server 9090`

Point a web browser to http://localhost:9090 to view the Prometheus console.

Choose a metric from the - *insert metric at cursor* menu, then choose *Execute*. Choose the *Graph* tab to show the metric over time. The following image shows `container_memory_usage_bytes` over time.

## Access to Dashboard

Use `make dashboard` to install Kubernetes Dashboard Web UI.

Follow this guide to create a service account https://docs.aws.amazon.com/eks/latest/userguide/dashboard-tutorial.html and access to Dashboard

## Logging with EFK stack

Use `make logging` to provision EFK stack.

Forward port 5601 for Kibana `kubectl port-forward kibana-866c457776-hlzqt 5601:5601 -n kube-logging` then access to http://localhost:5601
