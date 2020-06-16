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

  name = var.namespace
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

  single_nat_gateway     = true
  enable_nat_gateway     = true
  one_nat_gateway_per_az = false

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Terraform   = "true"
    Environment = var.namespace
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.namespace}-cluster" = "shared"
    "kubernetes.io/role/internal-elb"                = 1
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.namespace}-cluster" = "shared"
    "kubernetes.io/role/elb"                         = 1
  }
}

module "eks-cluster" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "12.1.0"
  cluster_name    = "${var.namespace}-cluster"
  cluster_version = "1.16"
  subnets         = module.vpc.private_subnets
  vpc_id          = module.vpc.vpc_id

  manage_aws_auth = true

  worker_groups = [
    {
      instance_type        = "m4.large"
      asg_desired_capacity = 2
    }
  ]
}

module "efs" {
  source = "git::https://github.com/cloudposse/terraform-aws-efs.git?ref=tags/0.16.0"

  namespace = "${var.namespace}"
  stage     = "test"
  name      = "app"
  region    = var.region
  vpc_id    = module.vpc.vpc_id
  subnets   = module.vpc.private_subnets

  security_groups = [
    module.eks-cluster.worker_security_group_id,
    module.ssh_sg.this_security_group_id
  ]
}

data "aws_ami" "amzn_linux" {
  most_recent = true
  name_regex  = "^amzn2-ami-hvm-2.0.*-x86_64-gp2"
  owners      = ["amazon"]

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "tls_private_key" "this" {
  algorithm = "RSA"
}

resource "local_file" "ssh_key" {
  content         = tls_private_key.this.private_key_pem
  filename        = "${path.module}/${var.namespace}.key"
  file_permission = "0600"
}

module "key_pair" {
  source = "terraform-aws-modules/key-pair/aws"

  key_name   = "${var.namespace}-key"
  public_key = tls_private_key.this.public_key_openssh
}

module "ssh_sg" {
  source  = "terraform-aws-modules/security-group/aws//modules/ssh"
  version = "~> 3.0"

  name        = "SSH"
  description = "Security group for SSH server with ssh ports open within VPC"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
}

module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 2.15.0"

  name           = "${var.namespace}-filestore"
  instance_count = 1

  ami                    = data.aws_ami.amzn_linux.image_id
  instance_type          = "t2.micro"
  key_name               = module.key_pair.this_key_pair_key_name
  monitoring             = true
  vpc_security_group_ids = [module.ssh_sg.this_security_group_id]
  subnet_id              = module.vpc.public_subnets[0]
  user_data_base64       = data.template_cloudinit_config.config.rendered

  tags = {
    Terraform   = "true"
    Environment = "${var.namespace}"
  }
}

data "template_cloudinit_config" "config" {
  gzip          = true
  base64_encode = true

  # Main cloud-config configuration file.
  part {
    filename     = "init.cfg"
    content_type = "text/cloud-config"
    content      = data.template_file.cloud_config.rendered
  }
}

data "template_file" "cloud_config" {
  template = file("${path.module}/templates/cloud_config.yaml")

  vars = {
    EFS_DNS_NAME = "${module.efs.dns_name}"
  }
}
