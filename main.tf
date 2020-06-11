data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  azs      = data.aws_availability_zones.available.names
  az_count = length(local.azs)
}

module "subnet_addrs" {
  source = "hashicorp/subnets/cidr"

  base_cidr_block = var.vpc_cidr

  networks = [
    {
      name : "public"
      new_bits : 4
    },
    {
      name : "private"
      new_bits : 2
    }
  ]
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.39.0"

  name = "tnguyen"
  cidr = var.vpc_cidr

  azs = data.aws_availability_zones.available.names
  private_subnets = [
    for num in range(local.az_count) :
    cidrsubnet(module.subnet_addrs.network_cidr_blocks["private"], 2, num)
  ]
  public_subnets = [
    for num in range(local.az_count) :
    cidrsubnet(module.subnet_addrs.network_cidr_blocks["public"], 2, num)
  ]

  enable_nat_gateway = true

  tags = {
    Terraform   = "true"
    Environment = "tnguyen"
  }
}

module "tnguyen-cluster" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = "tnguyen-cluster"
  cluster_version = "1.16"
  subnets         = module.vpc.private_subnets
  vpc_id          = module.vpc.vpc_id

  worker_groups = [
    {
      instance_type = "m4.large"
      asg_max_size  = 3
    }
  ]
}
