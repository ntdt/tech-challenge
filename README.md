# EKS application deployments

Provisionning EKS with terraform then deploy jobs

AWS EFS is used to store images and share to workers jobs.

Images are distributed in folders whose number is equal to number of workers.

An EC2 instance with a NFS mount to EFS is used to prepare images and provide interaction with user.

## Parameters

Edit terraform.tfvars to specify the number of *worker_count*, *region* and *vpc_cidr*

## Use make for tasks:

- *make build*: build docker image and push to docker hub

- *make init*: initialize terraform

- *make plan*: terraform plan

- *make apply*: terraform apply

- *make upload*: upload images to filestore EC2 instance

- *make run*: launch Jobs to process images

- *make download*: download images processed to *result*
