## 🔐 Fixing EKS Authentication Issue (Access Entry + Policy Association)

While working with the EKS cluster, you may encounter this error:

```
You must be logged in to the server (the server has asked for the client to provide credentials)
```

### 💡 Root Cause

This happens because AWS EKS uses a **new access management model**:

* **Access Entry** → Defines *who* (IAM user/role)
* **Access Policy Association** → Defines *what permissions*

By default, even if your IAM user has `AdministratorAccess`, EKS **does NOT automatically grant Kubernetes access**.

---

## ✅ Step-by-Step Fix

### 🔹 Step 1: Create Access Entry

Register your IAM user with the EKS cluster:

```bash
aws eks create-access-entry \
  --cluster-name <your-cluster-name> \
  --principal-arn <iam-role-arn>
```

---

### 🔹 Step 2: Associate Admin Policy

Grant cluster-level admin access:

```bash
aws eks associate-access-policy \
  --cluster-name <your-cluster-name> \
  --principal-arn <iam-role-arn> \
  --policy-arn arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy \
  --access-scope type=cluster

```

---

### 🔹 Step 3: Update kubeconfig

```bash
aws eks update-kubeconfig \
  --name <your-cluster-name> \
  --region <your-region>
```

---

### 🔹 Step 4: Verify Access

```bash
kubectl get nodes
kubectl get pods -A
```

---

## 🧠 Why This Happens

EKS Access Management works in two layers:

| Layer              | Purpose                             |
| ------------------ | ----------------------------------- |
| Access Entry       | Registers IAM identity with cluster |
| Policy Association | Grants permissions inside cluster   |

👉 You **cannot assign permissions without first creating the access entry**

---

## 🚀 Best Practice (Terraform Approach)

Instead of manual CLI steps, manage access using Terraform:

```hcl
access_entries = {
  admin = {
    principal_arn = "<iam-role-arn>"

    policy_associations = {
      admin = {
        policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

        access_scope = {
          type = "cluster"
        }
      }
    }
  }
}
```

Then run:

```bash
terraform apply
```

---

## 🎯 Key Takeaway

Even with full IAM permissions:

❌ IAM ≠ Kubernetes Access
✅ EKS requires explicit access mapping

This is a **critical real-world DevOps concept** when working with managed Kubernetes.
