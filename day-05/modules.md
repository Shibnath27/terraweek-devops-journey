# 📄 Day 05 – Terraform Modules: Build Reusable Infrastructure

## 🚀 Overview

Until now, all infrastructure was written in a single file. That works for learning—but not for real-world systems.

Today, I implemented **modular infrastructure** using **Terraform** by:

* Creating reusable EC2 and Security Group modules
* Calling modules multiple times
* Using an official VPC module from the registry

---

# 🧠 Task 1: Module Structure

## 📁 Project Layout

```
terraform-backend/
│ │
│ └── main.tf               #create s3 & dynamo for state lock
terraform-modules/
│
├── main.tf                 # Root module -- calls child modules
├── variables.tf            # Root variables
├── outputs.tf              # Root outputs
├── providers.tf            # Provider config
├── locals.tf
├── env/                    #environment-specific tfvars files
│   ├── dev.tfvars
│   └── prod.tfvars
└── modules/
    ├── ec2-instance/
    │   ├── main.tf         # EC2 resource definition
    │   ├── variables.tf    # Module inputs
    │   └── outputs.tf      # Module outputs
    │
    └── security-group/
        ├── main.tf         # Security group resource definition
        ├── variables.tf    # Module inputs
        └── outputs.tf      # Module outputs
```

---

## 🔍 Root vs Child Module

| Type         | Description                                   |
| ------------ | --------------------------------------------- |
| Root Module  | Entry point (where you run `terraform apply`) |
| Child Module | Reusable component called by root             |

---

# 💻 Task 2: EC2 Module

## 📁 modules/ec2-instance/variables.tf

```hcl
variable "ami_id" {
  type = string
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "subnet_id" {
  type = string
}

variable "security_group_ids" {
  type = list(string)
}

variable "instance_name" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
```

---

## 📁 modules/ec2-instance/main.tf

```hcl
resource "aws_instance" "this" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids

  tags = merge(var.tags, {
    Name = var.instance_name
  })
}
```

---

## 📁 modules/ec2-instance/outputs.tf

```hcl
output "instance_id" {
  value = aws_instance.this.id
}

output "public_ip" {
  value = aws_instance.this.public_ip
}

output "private_ip" {
  value = aws_instance.this.private_ip
}
```

---

# 🔐 Task 3: Security Group Module

## 📁 modules/security-group/variables.tf

```hcl
variable "vpc_id" {
  type = string
}

variable "sg_name" {
  type = string
}

variable "ingress_ports" {
  type    = list(number)
  default = [22, 80]
}

variable "tags" {
  type    = map(string)
  default = {}
}
```

---

## 📁 modules/security-group/main.tf

```hcl
resource "aws_security_group" "this" {
  name   = var.sg_name
  vpc_id = var.vpc_id

  dynamic "ingress" {
    for_each = var.ingress_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}
```

---

## 📁 modules/security-group/outputs.tf

```hcl
output "sg_id" {
  value = aws_security_group.this.id
}
```

---

# 🔗 Task 4: Root Module Wiring

## 📁 main.tf

```hcl
provider "aws" {
  region = var.region
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Simple VPC (temporary before registry module)
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
}

# SG Module
module "web_sg" {
  source        = "./modules/security-group"
  vpc_id        = aws_vpc.main.id
  sg_name       = "terraweek-web-sg"
  ingress_ports = [22, 80, 443]
  tags          = local.common_tags
}

# EC2 Modules (Reusability)
module "web_server" {
  source             = "./modules/ec2-instance"
  ami_id             = data.aws_ami.amazon_linux.id
  subnet_id          = aws_subnet.public.id
  security_group_ids = [module.web_sg.sg_id]
  instance_name      = "terraweek-web"
  tags               = local.common_tags
}

module "api_server" {
  source             = "./modules/ec2-instance"
  ami_id             = data.aws_ami.amazon_linux.id
  subnet_id          = aws_subnet.public.id
  security_group_ids = [module.web_sg.sg_id]
  instance_name      = "terraweek-api"
  tags               = local.common_tags
}
```

---

## 📤 Outputs

```hcl
output "web_server_ip" {
  value = module.web_server.public_ip
}

output "api_server_ip" {
  value = module.api_server.public_ip
}
```

---

# 🌐 Task 5: Use Registry Module (VPC)

Replace manual VPC:

```hcl
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "terraweek-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["ap-south-1a", "ap-south-1b"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.3.0/24", "10.0.4.0/24"]

  enable_nat_gateway   = false
  enable_dns_hostnames = true

  tags = local.common_tags
}
```

---

## 🔍 Key Insight

👉 Registry module creates:

* VPC
* Subnets
* Route tables
* IGW

👉 Much more than manual setup

---

## 📁 Module Download Location

```
.terraform/modules/
```

---

# 🧠 Task 6: Module Versioning

| Version Syntax    | Meaning         |
| ----------------- | --------------- |
| `"5.1.0"`         | Exact version   |
| `"~> 5.0"`        | Any 5.x version |
| `">= 5.0, < 6.0"` | Range           |

---

## 🔹 Upgrade Modules

```bash
terraform init -upgrade
```

---

## 🔹 State Representation

```bash
terraform state list
```

Example:

```
module.vpc.aws_vpc.this
module.web_server.aws_instance.this
module.web_sg.aws_security_group.this
```
## 🔹 tfvars-based approach
📄 dev.tfvars
```bash
project_name = "terraweek"
environment  = "dev"
instance_type = "t2.micro"
```
📄 prod.tfvars
```bash
project_name  = "terraweek"
environment   = "prod"
instance_type = "t3.small"
```
3. Run explicitly
Dev
```bash
terraform plan -var-file="dev.tfvars"
```
Prod
```bash
terraform plan -var-file="prod.tfvars"
```
---

# 🔥 Final Step

```bash
terraform destroy
```

---

# 🧠 Key Learnings

* Modules = reusable infrastructure components
* DRY principle (Don’t Repeat Yourself)
* Registry modules save time and reduce errors
* Same module → multiple deployments

---

# 📌 Conclusion

Today I moved from:
❌ Writing infrastructure
➡
✅ Designing reusable infrastructure systems

This is a **critical DevOps skill for scaling environments**.

---

