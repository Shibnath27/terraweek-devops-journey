terraform {
  backend "s3" {
    bucket         = "terraweek-state-shibnath"
    key            = "dev/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraweek-state-lock"
    encrypt        = true
  }
}

