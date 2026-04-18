# 🚀 Day 66 – Provisioning Amazon EKS with Terraform

## 📌 Overview

Today I provisioned a fully functional **Amazon EKS (Elastic Kubernetes Service)** cluster using Terraform modules — moving from manual Kubernetes setup to a **production-style, automated infrastructure approach**.

This setup is:

* Fully automated via Infrastructure as Code
* Reproducible across environments
* Destroyable with a single command

---

# 🎯 Objectives

* Provision an EKS cluster using Terraform
* Configure networking (VPC, subnets, NAT)
* Deploy managed node groups
* Connect using kubectl
* Deploy a sample Nginx application
* Clean up all resources

---

# 🏗️ Architecture

* **VPC Module** (Terraform Registry)

  * Public + Private subnets across 2 AZs
  * NAT Gateway (single for cost optimization)

* **EKS Module** (Terraform Registry)

  * Managed Kubernetes control plane
  * Managed node group (EC2 instances)

* **Kubernetes Layer**

  * Nginx Deployment (3 replicas)
  * LoadBalancer Service (external access)

---

# 📁 Project Structure

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

# ⚙️ Terraform Configuration

## 🔹 Providers

* AWS Provider (`~> 5.0`)
* Kubernetes Provider (`~> 2.0`)

## 🔹 Modules Used

* VPC: terraform-aws-modules/vpc/aws
* EKS: terraform-aws-modules/eks/aws

---

# 🚀 Deployment Steps

## 1. Initialize Terraform

```bash
terraform init
```

## 2. Review Plan

```bash
terraform plan
```

## 3. Apply Configuration

```bash
terraform apply
```

⏳ *EKS cluster provisioning takes ~10–15 minutes*

---

# 🔗 Connect to Cluster

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

✔ Expected:

* Worker nodes in **Ready** state
* kube-system pods running

---

# 🌐 Deploy Application

## Apply Nginx Deployment

```bash
kubectl apply -f k8s/nginx-deployment.yaml
```

## Check Service

```bash
kubectl get svc nginx-service -w
```

✔ Access Nginx using LoadBalancer URL

---

# 🔍 Verification Commands

```bash
kubectl get nodes
kubectl get pods
kubectl get deployments
kubectl get svc
```

---

# 🧠 Key Learnings

## 🔹 Why EKS Needs Public & Private Subnets

* **Public Subnets** → Used by Load Balancers
* **Private Subnets** → Secure worker nodes

---

## 🔹 Subnet Tagging (Critical for EKS)

```hcl
"kubernetes.io/role/elb" = 1
```

→ Enables external LoadBalancer

```hcl
"kubernetes.io/role/internal-elb" = 1
```

→ Enables internal services

---

## 🔹 Infrastructure Insights

* EKS provisioning creates **30+ AWS resources**
* Terraform modules abstract complex configurations
* Node groups are auto-managed by AWS

---

# ⚠️ Important Notes

* EKS setup includes **NAT Gateway (costly)**
* Always destroy resources after testing
* Ensure LoadBalancer is deleted before destroying

---

# 💣 Cleanup (Mandatory)

## Step 1: Delete Kubernetes Resources

```bash
kubectl delete -f k8s/nginx-deployment.yaml
```

## Step 2: Destroy Infrastructure

```bash
terraform destroy
```

✔ Verify:

* No EKS cluster
* No EC2 instances
* No NAT Gateway
* No Load Balancers

---

# 📊 Outcome

* ✅ EKS cluster provisioned via Terraform
* ✅ kubectl configured successfully
* ✅ Application deployed and accessible
* ✅ Infrastructure cleaned up completely

---

# 🔥 Next Steps

* Helm deployments
* Ingress Controllers (ALB)
* CI/CD with GitHub Actions
* GitOps (ArgoCD)

---

# 👨‍💻 Author

**Shibnath**
DevOps & Cloud Enthusiast 🚀

---

# ⭐ If you found this useful, consider giving the repo a star!
