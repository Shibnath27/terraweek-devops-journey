# 📄 Day 03 – Variables, Outputs, Data Sources & Expressions

## 🚀 Overview

On Day 02, my Terraform config worked — but it was rigid and full of hardcoded values.

Today, I transformed it into a **dynamic, reusable, environment-aware infrastructure** using:

* Variables
* Outputs
* Data sources
* Locals & expressions

Using **Terraform**, I built a configuration that works across **dev, staging, and prod** without changing core code.

---

# 🧠 Task 1: Extract Variables

## 🔹 Step 1: Create `variables.tf`

```hcl
variable "region" {
  type    = string
  default = "us-east-2"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "subnet_cidr" {
  type    = string
  default = "10.0.1.0/24"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "project_name" {
  type = string
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "allowed_ports" {
  type    = list(number)
  default = [22, 80, 443]
}

variable "extra_tags" {
  type    = map(string)
  default = {}
}
```

---

## 🔹 Step 2: Update `provider.tf`

```hcl
provider "aws" {
  region = var.region
}
```

---

## 🔹 Step 3: Replace Hardcoded Values in `main.tf`

Example:

```hcl
cidr_block = var.vpc_cidr
```

---

## 🔍 Variable Types in Terraform

* `string`
* `number`
* `bool`
* `list`
* `map`

---

# ⚙️ Task 2: Variable Files & Precedence

## 🔹 terraform.tfvars

```hcl
project_name  = "terraweek"
environment   = "dev"
instance_type = "t2.micro"
```

---

## 🔹 prod.tfvars

```hcl
project_name  = "terraweek"
environment   = "prod"
instance_type = "t3.small"
vpc_cidr      = "10.1.0.0/16"
subnet_cidr   = "10.1.1.0/24"
```

---

## 🔹 Run Commands

```bash
terraform plan
terraform plan -var-file="prod.tfvars"
terraform plan -var="instance_type=t2.nano"
export TF_VAR_environment="staging"
terraform plan
```

---

## 🔍 Variable Precedence (Low → High)

1. Default values in variables.tf
2. Environment variables (`TF_VAR_`)
3. terraform.tfvars
4. *.auto.tfvars
5. CLI `-var` / `-var-file`

---

# 📤 Task 3: Outputs

## 🔹 outputs.tf

```hcl
output "vpc_id" {
  value = aws_vpc.main.id
}

output "subnet_id" {
  value = aws_subnet.public.id
}

output "instance_id" {
  value = aws_instance.main.id
}

output "instance_public_ip" {
  value = aws_instance.main.public_ip
}

output "instance_public_dns" {
  value = aws_instance.main.public_dns
}

output "security_group_id" {
  value = aws_security_group.sg.id
}
```

---

## 🔹 Commands

```bash
terraform apply
terraform output
terraform output instance_public_ip
terraform output -json
```

---

# 🔎 Task 4: Data Sources

## 🔹 AMI Lookup (Dynamic)

```hcl
data "aws_ami" "amazon_linux" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}
```

---

## 🔹 Availability Zones

```hcl
data "aws_availability_zones" "available" {}
```

Use it:

```hcl
availability_zone = data.aws_availability_zones.available.names[0]
```

---

## 🔍 Resource vs Data Source

| Resource               | Data Source         |
| ---------------------- | ------------------- |
| Creates infrastructure | Reads existing data |
| Managed by Terraform   | External lookup     |

---

# 🧩 Task 5: Locals & Tagging

## 🔹 locals.tf

```hcl
locals {
  name_prefix = "${var.project_name}-${var.environment}"

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
```

---

## 🔹 Example Usage

```hcl
tags = merge(local.common_tags, {
  Name = "${local.name_prefix}-server"
})
```

---

# 🧮 Task 6: Functions & Expressions

## 🔹 Terraform Console

```bash
terraform console
```

---

## 🔹 Useful Functions

### 1. upper()

```hcl
upper("terraweek") → "TERRAWEEK"
```

### 2. join()

```hcl
join("-", ["terra", "week"]) → "terra-week"
```

### 3. format()

```hcl
format("arn:aws:s3:::%s", "bucket")
```

### 4. lookup()

```hcl
lookup({dev="t2.micro", prod="t3.small"}, "dev")
```

### 5. cidrsubnet()

```hcl
cidrsubnet("10.0.0.0/16", 8, 1)
```

---

## 🔹 Conditional Expression

```hcl
instance_type = var.environment == "prod" ? "t3.small" : "t2.micro"
```

✔ Changes instance type based on environment

---

# 🧠 Key Learnings

* Terraform configs should never be hardcoded
* Variables enable **reusability and flexibility**
* Data sources make configs **region-independent**
* Outputs expose important infrastructure data
* Locals enforce **consistent naming and tagging**

---

# 📌 Conclusion

Today I transformed my Terraform configuration from:
❌ Static & fragile
➡
✅ Dynamic, reusable, environment-aware infrastructure

This is a major step toward **production-grade Infrastructure as Code**.

---


