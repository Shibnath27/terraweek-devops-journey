

# 📄 Day 02 – Providers, Resources & Dependencies (AWS Infra with Terraform)

## 🚀 Overview

Today I moved from standalone resources to building a **connected AWS infrastructure stack** using **Terraform**.

I created a full networking setup:

* VPC
* Subnet
* Internet Gateway
* Route Table
* Security Group
* EC2 Instance

More importantly, I learned **how Terraform handles dependencies automatically**.

---

## ⚙️ Task 1: AWS Provider Setup

### 🔹 providers.tf

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}
```

### 🔍 Observations

#### ✔ Installed Provider Version

After running:

```bash
terraform init
```

Terraform installed the latest compatible version:

```
~> 5.0 → installs latest 5.x (e.g., 5.30.0)
```

---

### 📌 Version Constraints Explained

| Constraint | Meaning                                        |
| ---------- | ---------------------------------------------- |
| `~> 5.0`   | Any version >= 5.0 and < 6.0                   |
| `>= 5.0`   | Anything 5.0 or higher (even breaking changes) |
| `= 5.0.0`  | Only exact version                             |

👉 `~>` is safest for production (avoids breaking upgrades)

---

### 🔐 .terraform.lock.hcl

* Locks provider versions
* Ensures consistent installs across environments
* Prevents unexpected upgrades

---

## 🌐 Task 2: Build VPC Infrastructure

### 🔹 main.tf

```hcl
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "TerraWeek-VPC"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "TerraWeek-Public-Subnet"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "TerraWeek-IGW"
  }
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "TerraWeek-RT"
  }
}

resource "aws_route_table_association" "assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.rt.id
}
```

✔ Verified all resources connected in AWS console

---

## 🔗 Task 3: Implicit Dependencies

### 🔹 How Terraform Understands Order

Terraform builds a **dependency graph internally**.

Example:

```hcl
vpc_id = aws_vpc.main.id
```

👉 This tells Terraform:

* Create VPC first
* Then create subnet

---

### 🔍 Key Answers

**Q: How does Terraform know order?**
→ By analyzing references (`aws_vpc.main.id`)

**Q: What if subnet is created before VPC?**
→ AWS API fails (invalid VPC ID)

---

### 🔹 Implicit Dependencies in This Config

* Subnet → depends on VPC
* Internet Gateway → depends on VPC
* Route Table → depends on VPC + IGW
* Route Table Association → depends on subnet + route table

---

## 🔐 Task 4: Security Group & EC2

```hcl
resource "aws_security_group" "sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "TerraWeek-SG"
  }
}

resource "aws_instance" "main" {
  ami                         = "ami-0f5ee92e2d63afc18"
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "TerraWeek-Server"
  }
}
```

✔ EC2 launched with public IP
✔ Security group applied successfully

---

## 🔗 Task 5: Explicit Dependencies (`depends_on`)

```hcl
resource "aws_s3_bucket" "logs" {
  bucket = "shibnath-logs-bucket-unique"

  depends_on = [aws_instance.main]
}
```

### 🔍 Why Use `depends_on`?

Used when **no direct reference exists**, but order still matters.

---

### 📌 Real-world Use Cases

1. Ensure DB is created before app deployment
2. Wait for IAM roles before attaching policies

---

## 📊 Dependency Graph

Now visualize the entire dependency tree:

```bash
terraform graph | dot -Tpng > graph.png
```
If you don't have dot (Graphviz) installed, use:

```bash
terraform graph
```

and paste the output into an online Graphviz viewer.

✔ Visualizes full infrastructure dependency tree

---

## 🔄 Task 6: Lifecycle Rules

```hcl
lifecycle {
  create_before_destroy = true
}
```

### 🔍 Behavior

* New instance created first
* Old instance destroyed later
* Prevents downtime

---

### 📌 Lifecycle Arguments

| Argument                | Purpose                        |
| ----------------------- | ------------------------------ |
| `create_before_destroy` | Zero downtime deployments      |
| `prevent_destroy`       | Protect critical resources     |
| `ignore_changes`        | Ignore external/manual changes |

---

## 🔥 Destroy Process

```bash
terraform destroy
```

✔ Terraform deletes resources in **reverse dependency order**:

* EC2 → SG → Route → IGW → Subnet → VPC

---

## 🧠 Key Learnings

* Terraform automatically builds a **dependency graph**
* Order is determined by **resource references**
* `depends_on` is used for **manual control**
* Lifecycle rules enable **production-safe deployments**

---

## 📌 Conclusion

Today was a major shift from:
👉 Creating resources → Designing infrastructure systems

I now understand:

* How infrastructure components are connected
* How Terraform manages dependencies internally
* How to safely control resource lifecycle

