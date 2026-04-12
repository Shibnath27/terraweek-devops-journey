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

resource "aws_s3_bucket" "my_bucket" {
  bucket = "shibnath-terraform-day61-unique"
}

resource "aws_instance" "my_ec2" {
  ami           = "ami-0d76b909de1a0595d"
  instance_type = "t3.micro"

  tags = {
    Name = "TerraWeek-Modified"
  }
}
