terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "6.23.0"
    }
  }
  backend "s3" {
  bucket         = "tf-state-fullstack-chatapp"
  key            = "terraform.tfstate"
  region         = "us-east-1"
  encrypt        = true
}
}

provider "aws" {
  region = "us-east-1"
}