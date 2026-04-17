# -----------------------------
# Data Source (Dynamic AMI)
# -----------------------------
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

data "aws_availability_zones" "available" {}
# -----------------------------
# VPC (Registry Module)
# -----------------------------
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = local.name_prefix
  cidr = var.vpc_cidr

  azs             = slice(data.aws_availability_zones.available.names, 0, 2)
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets

  enable_nat_gateway   = false
  enable_dns_hostnames = true
  map_public_ip_on_launch = true

  tags = local.common_tags
}

# -----------------------------
# Security Group Module
# -----------------------------
module "web_sg" {
  source        = "./modules/security-group"
  vpc_id        = module.vpc.vpc_id
  sg_name       = "${local.name_prefix}-sg"
  ingress_ports = var.allowed_ports
  tags          = local.common_tags
}

# -----------------------------
# EC2 Module - Web Server
# -----------------------------
module "web_server" {
  source             = "./modules/ec2-instance"
  ami_id             = data.aws_ami.amazon_linux.id
  instance_type      = var.environment == "prod" ? "t3.small" : var.instance_type
  subnet_id          = module.vpc.public_subnets[0]
  security_group_ids = [module.web_sg.sg_id]
  instance_name      = "${local.name_prefix}-web"
  tags               = local.common_tags
}

# -----------------------------
# EC2 Module - API Server
# -----------------------------
module "api_server" {
  source             = "./modules/ec2-instance"
  ami_id             = data.aws_ami.amazon_linux.id
  instance_type      = var.environment == "prod" ? "t3.small" : var.instance_type
  subnet_id          = module.vpc.public_subnets[0]
  security_group_ids = [module.web_sg.sg_id]
  instance_name      = "${local.name_prefix}-api"
  tags               = local.common_tags
}
