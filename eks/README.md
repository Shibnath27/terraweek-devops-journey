# 🚀 Terraform EKS (Complete Step-by-Step Guide)

---

# 📁 Step 1: Project Structure

Create this inside your repo:

```bash
mkdir -p day-66-eks/terraform-eks/k8s
cd day-66-eks/terraform-eks
```

Final structure:

```
terraform-eks/
├── providers.tf
├── variables.tf
├── vpc.tf
├── eks.tf
├── outputs.tf
├── terraform.tfvars
└── k8s/
    └── nginx-deployment.yaml
```

---

# ⚙️ Step 2: providers.tf

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  region = var.region
}
```

---

# 📥 Step 3: variables.tf

```hcl
variable "region" {
  type    = string
  default = "ap-south-1"
}

variable "cluster_name" {
  type    = string
  default = "terraweek-eks"
}

variable "cluster_version" {
  type    = string
  default = "1.31"
}

variable "node_instance_type" {
  type    = string
  default = "t3.medium"
}

variable "node_desired_count" {
  type    = number
  default = 2
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}
```

---

# 🌐 Step 4: vpc.tf

```hcl
data "aws_availability_zones" "available" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "terraweek-vpc"
  cidr = var.vpc_cidr

  azs             = slice(data.aws_availability_zones.available.names, 0, 2)
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.3.0/24", "10.0.4.0/24"]

  enable_nat_gateway     = true
  single_nat_gateway     = true
  enable_dns_hostnames   = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }
}
```

---

# ☸️ Step 5: eks.tf

```hcl
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  cluster_endpoint_public_access = true

  eks_managed_node_groups = {
    terraweek_nodes = {
      instance_types = [var.node_instance_type]

      min_size     = 1
      max_size     = 3
      desired_size = var.node_desired_count
    }
  }

  tags = {
    Environment = "dev"
    Project     = "TerraWeek"
  }
}
```

---

# 📤 Step 6: outputs.tf

```hcl
output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "region" {
  value = var.region
}
```

---

# 📄 Step 7: terraform.tfvars

```hcl
region = "ap-south-1"
```

---

# 🚀 Step 8: Run Terraform

```bash
terraform init
terraform plan
terraform apply
```

⏳ Wait 10–15 minutes

---

# 🔗 Step 9: Connect kubectl

```bash
aws eks update-kubeconfig --name terraweek-eks --region ap-south-1
```

---

# ✅ Verify Cluster

```bash
kubectl get nodes
kubectl get pods -A
kubectl cluster-info
```

✔ Expect:

* 2 nodes in **Ready**
* kube-system pods running

---

# 🌐 Step 10: Deploy Nginx

## `k8s/nginx-deployment.yaml`

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-terraweek
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  type: LoadBalancer
  selector:
    app: nginx
  ports:
  - port: 80
    targetPort: 80
```

---

## Apply:

```bash
kubectl apply -f k8s/nginx-deployment.yaml
```

---

## Get External IP:

```bash
kubectl get svc nginx-service -w
```

👉 Open browser → access Nginx

---

# 🔍 Verification

```bash
kubectl get nodes
kubectl get pods
kubectl get svc
kubectl get deployments
```

---

# 💣 Step 11: CLEANUP (CRITICAL)

## Delete workload first:

```bash
kubectl delete -f k8s/nginx-deployment.yaml
```

Wait until LoadBalancer is deleted.

---

## Destroy infra:

```bash
terraform destroy
```

---

# 🧠 Key Concepts (Important for README)

## Why Public + Private Subnets?

* Public → LoadBalancer (external access)
* Private → Worker nodes (secure)

---

## Why Subnet Tags?

```
kubernetes.io/role/elb
```

👉 Allows AWS to place public load balancers

```
kubernetes.io/role/internal-elb
```

👉 For internal services

---

# ⚠️ Cost Warning

EKS creates:

* NAT Gateway 💸
* EC2 nodes
* Load Balancer

👉 Always destroy after use

---

# 🎯 Final Outcome

✔ EKS cluster via Terraform
✔ kubectl connected
✔ Nginx deployed
✔ Clean destroy

---
