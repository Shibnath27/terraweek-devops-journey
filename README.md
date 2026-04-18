# 🚀 TerraWeek DevOps Journey

This repository documents my hands-on journey into **Terraform, AWS, and Kubernetes**, progressing from basic Infrastructure as Code (IaC) concepts to provisioning a **production-style EKS cluster using Terraform modules**.

---

# 📅 Learning Progress

# 📅 Day 01 – Terraform Basics & First Infrastructure

## 🔍 What I Learned

* Introduction to **Infrastructure as Code (IaC)**
* Why IaC is critical in modern DevOps:

  * Eliminates manual provisioning errors
  * Enables repeatable infrastructure
  * Supports version control & automation

## ⚙️ Hands-on

* Installed Terraform & AWS CLI
* Configured AWS credentials
* Created:

  * S3 Bucket
  * EC2 Instance

## 🧠 Key Concepts

* Terraform lifecycle:

  ```
  terraform init → plan → apply → destroy
  ```
* Understanding `.terraform/` directory
* Introduction to **state file (`terraform.tfstate`)**

---

# 📅 Day 02 – Providers, Resources & Dependencies

## 🔍 What I Learned

* Terraform **providers** (AWS provider)
* Resource creation & dependency management
* Implicit vs explicit dependencies

## ⚙️ Hands-on

Built a complete AWS networking stack:

* VPC
* Subnet
* Internet Gateway
* Route Table
* Security Group
* EC2 Instance

## 🧠 Key Concepts

* Implicit dependency:

  ```hcl
  vpc_id = aws_vpc.main.id
  ```
* Terraform builds dependency graph automatically

## 🔗 Visualization

* Used:

  ```bash
  terraform graph
  ```
* Understood resource creation order

---

# 📅 Day 03 – Variables, Outputs & Data Sources

## 🔍 What I Learned

* Writing **dynamic and reusable Terraform code**
* Eliminating hardcoded values

## ⚙️ Hands-on

* Created:

  * `variables.tf`
  * `outputs.tf`
  * `terraform.tfvars`
* Used **data sources**:

  * Fetch latest Amazon Linux AMI
* Implemented:

  * Conditional expressions
  * Built-in functions

## 🧠 Key Concepts

* Variable types:

  * string, number, bool, list, map
* Data source vs resource
* Outputs for exposing infrastructure data

---

# 📅 Day 04 – State Management & Remote Backend

## 🔍 What I Learned

* Importance of Terraform **state file**
* Risks of local state:

  * Data loss
  * No collaboration
  * No locking

## ⚙️ Hands-on

* Created:

  * S3 bucket (remote state storage)
  * DynamoDB table (state locking)
* Migrated state from local → remote backend

## 🧠 Key Concepts

* Remote backend configuration:

  ```hcl
  backend "s3" {}
  ```
* State locking prevents concurrent changes
* State drift detection and reconciliation

## 🔥 Advanced

* Imported existing AWS resource into Terraform
* Used:

  ```
  terraform state mv
  terraform state rm
  ```

---

# 📅 Day 05 – Terraform Modules & Reusability

## 🔍 What I Learned

* Writing **modular and reusable infrastructure**
* Difference between:

  * Root module
  * Child modules

## ⚙️ Hands-on

### 🧩 Custom Modules Built:

* EC2 Instance Module
* Security Group Module

### 🔁 Reusability:

* Deployed multiple EC2 instances using same module

### 🌐 Registry Module:

* Used official AWS VPC module:

  ```
  terraform-aws-modules/vpc/aws
  ```

## 🧠 Key Concepts

* Module structure:

  ```
  modules/
    ec2-instance/
    security-group/
  ```
* Passing variables between modules
* Output values from modules

---

# ⚙️ Environment Management

## 📁 Structure

```
env/
  dev.tfvars
  prod.tfvars
```

## 🚀 Usage

```bash
terraform plan -var-file="env/dev.tfvars"
terraform plan -var-file="env/prod.tfvars"
```

## 🧠 Learning

* Avoid interactive prompts
* Use `.tfvars` for reproducibility
* Environment-specific deployments

---

# 📌 What This Repo Covers

* Infrastructure as Code using Terraform
* AWS resource provisioning (VPC, EC2, S3)
* State management & remote backends
* Modular Terraform architecture
* Kubernetes cluster provisioning using EKS
* Application deployment on Kubernetes

---

## 🔹 Terraform + EKS (Production-Level)

🚀 **Major milestone: Provisioned a Kubernetes cluster using Terraform**

### What I Built

* VPC with public & private subnets
* Amazon EKS cluster using Terraform module
* Managed node group (EC2 instances)
* Kubernetes deployment (Nginx)
* LoadBalancer service for external access

### Key Concepts

* Infrastructure abstraction using Terraform modules
* Kubernetes cluster provisioning via IaC
* Networking design for Kubernetes (public vs private subnets)
* Subnet tagging for LoadBalancer integration

---

# 🏗️ Project Structure

```
terraweek-devops-journey/
├── day-01/
├── day-02/
├── day-03/
├── day-04/
├── day-05/
├── day-eks/
│   └── terraform-eks/
│       ├── providers.tf
│       ├── variables.tf
│       ├── vpc.tf
│       ├── eks.tf
│       ├── outputs.tf
│       ├── terraform.tfvars
│       └── k8s/
│           └── nginx-deployment.yaml
```

---

# ⚙️ Technologies Used

* Terraform
* AWS (EC2, S3, VPC, EKS)
* Kubernetes
* kubectl

---

# 🧠 Key Takeaways

* Terraform is **declarative** and scalable
* State management is critical for production systems
* Modules enable reusable infrastructure
* Remote backends are mandatory for teams
* EKS provisioning involves complex dependencies abstracted by modules
* Kubernetes workloads can be deployed on fully automated infrastructure

---

# ⚠️ Important Notes

* EKS setup includes **NAT Gateway (costly resource)**
* Always destroy infrastructure after testing:

  ```bash
  terraform destroy
  ```

---

# 🔥 Next Goals

* Helm charts for Kubernetes deployments
* AWS ALB Ingress Controller
* CI/CD pipeline for Terraform + Kubernetes
* GitOps (ArgoCD)

---

# 📌 Author

**Shibnath**
DevOps & Cloud Enthusiast 🚀

---

# ⭐ If you find this useful, consider giving a star!
