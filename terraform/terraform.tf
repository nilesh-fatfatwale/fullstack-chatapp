terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.95.0"
    }
  }

  backend "s3" {
    bucket  = "tf-state-fullstackchatapp"
    key     = "terraform.tfstate"
    dynamodb_table = "dynamodbtable"
    region  = "us-east-1"
    encrypt = true
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "mybucket" {
  bucket = "tf-state-fullstackchatapp"
}
resource "aws_s3_bucket_versioning" "aws_s3_bucket_versioning" {
  bucket = aws_s3_bucket.mybucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_dynamodb_table" "dynamodb_table" {
  name = "dynamodbtable"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}