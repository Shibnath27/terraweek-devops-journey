# 📄 Day 04 – Terraform State Management & Remote Backends

## 🚀 Overview

Today I learned how Terraform manages its **state**, which is the **single source of truth** mapping my configuration to real infrastructure.

Using **Terraform**, I:

* Explored local state
* Migrated state to remote backend (S3)
* Implemented state locking (DynamoDB)
* Imported existing resources
* Handled state drift

---

# 🧠 Task 1: Inspect Current State

## 🔹 Commands Used

```bash
terraform show
terraform state list
terraform state show aws_instance.main
terraform state show aws_vpc.main
```

---

## 🔍 Findings

### ✔ How many resources?

Run:

```bash
terraform state list
```

👉 Lists all resources Terraform manages (VPC, subnet, IGW, EC2, etc.)

---

### ✔ What EC2 state stores

Not just what you defined — it includes:

* Instance ID
* Public IP / Private IP
* AMI ID
* Availability Zone
* Security groups
* Tags
* Network interfaces

👉 State stores **full real-world metadata**

---

### ✔ Serial Number

Inside `terraform.tfstate`:

```json
"serial": 12
```

👉 Represents:

* Version of state file
* Incremented after each apply

---

# ☁️ Task 2: Remote Backend (S3 + DynamoDB)

## 🔹 Step 1: Create Backend Infra

```bash
aws s3api create-bucket \
  --bucket terraweek-state-shibnath \
  --region ap-south-1 \
  --create-bucket-configuration LocationConstraint=ap-south-1
```

```bash
aws s3api put-bucket-versioning \
  --bucket terraweek-state-shibnath \
  --versioning-configuration Status=Enabled
```

```bash
aws dynamodb create-table \
  --table-name terraweek-state-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region ap-south-1
```

---

## 🔹 Step 2: Add Backend Block

```hcl
terraform {
  backend "s3" {
    bucket         = "terraweek-state-shibnath"
    key            = "dev/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraweek-state-lock"
    encrypt        = true
  }
}
```

---

## 🔹 Step 3: Initialize

```bash
terraform init
```

👉 Choose:

```
yes → migrate state
```

---

## 🔍 Verification

* State file appears in S3
* Local state removed
* `terraform plan` → **No changes**

---

# 🔐 Task 3: State Locking

## 🔹 Test

Terminal 1:

```bash
terraform apply
```

Terminal 2:

```bash
terraform plan
```

---

## 🔴 Expected Error

```
Error acquiring the state lock
Lock Info:
  ID: <lock-id>
```

---

## 🧠 Why Locking Matters

* Prevents **parallel execution**
* Avoids **state corruption**
* Critical in team environments

---

## 🔧 Fix Stuck Lock

```bash
terraform force-unlock <LOCK_ID>
```

---

# 📥 Task 4: Import Existing Resource

## 🔹 Step 1: Create Bucket Manually

Example:

```
terraweek-import-test-shibnath
```

---

## 🔹 Step 2: Add Resource Block

```hcl
resource "aws_s3_bucket" "imported" {
  bucket = "terraweek-import-test-shibnath"
}
```

---

## 🔹 Step 3: Import

```bash
terraform import aws_s3_bucket.imported terraweek-import-test-shibnath
```

---

## 🔍 Key Insight

| Import                              | Create                     |
| ----------------------------------- | -------------------------- |
| Brings existing resource into state | Creates new resource       |
| No infrastructure change            | Infrastructure provisioned |

---

# 🔧 Task 5: State Surgery

## 🔹 Rename Resource

```bash
terraform state mv aws_s3_bucket.imported aws_s3_bucket.logs_bucket
```

👉 Update `.tf` accordingly

---

## 🔹 Remove from State

```bash
terraform state rm aws_s3_bucket.logs_bucket
```

👉 Resource still exists in AWS, but Terraform forgets it

---

## 🔁 Re-import

```bash
terraform import aws_s3_bucket.logs_bucket terraweek-import-test-shibnath
```

---

## 🧠 Real Use Cases

### `state mv`

* Renaming resources
* Refactoring modules

### `state rm`

* Stop managing resource
* Handle accidental imports

---

# ⚠️ Task 6: State Drift

## 🔹 Simulate Drift

Manually change in AWS:

* EC2 tag → `"ManuallyChanged"`

---

## 🔹 Detect Drift

```bash
terraform plan
```

👉 Shows difference between:

* Desired state (code)
* Actual state (AWS)

---

## 🔹 Fix Drift

```bash
terraform apply
```

✔ Restores original config

---

## 🔍 Prevention Strategies

* Restrict AWS console access
* Use CI/CD for all changes
* Enforce IaC-only modifications

---

# 🧠 Key Learnings

* State file = **source of truth**
* Remote backend = **team-safe**
* Locking = **prevents corruption**
* Import = **adopt existing infra**
* Drift = **real-world inevitability**

---

# 📌 Conclusion

Today I moved from:
❌ Local, fragile state
➡
✅ Production-ready remote state management

This is one of the **most critical skills in Terraform and DevOps**.

---