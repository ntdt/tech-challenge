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

## Parameters

Edit `terraform.tfvars` to specify the number of `worker_count`, `region` and `vpc_cidr`

## Use make for tasks:

- `make build`: build docker image and push to docker hub

- `make init`: initialize terraform

- `make plan`: terraform plan

- `make apply`: terraform apply

- `make upload`: upload images to filestore EC2 instance

- `make run`: launch Jobs to process images

- `make download`: download images processed to *result*
