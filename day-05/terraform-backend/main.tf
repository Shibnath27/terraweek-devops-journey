provider "aws" {
  region = "us-west-2"
}

# -----------------------------
# S3 Bucket for Terraform State
# -----------------------------
resource "aws_s3_bucket" "tf_state" {
  bucket = "terraweek-state-shibnath"

  tags = {
    Name        = "Terraform State Bucket"
    Environment = "dev"
  }
}

# Enable Versioning
resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.tf_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Enable Encryption (Best Practice)
resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = aws_s3_bucket.tf_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block Public Access (CRITICAL)
resource "aws_s3_bucket_public_access_block" "block" {
  bucket = aws_s3_bucket.tf_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# -----------------------------
# DynamoDB Table for Locking
# -----------------------------
resource "aws_dynamodb_table" "tf_lock" {
  name         = "terraweek-state-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "Terraform Lock Table"
    Environment = "dev"
  }
}

