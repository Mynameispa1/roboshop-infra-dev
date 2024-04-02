terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.31.0" # AWS provider version, not terraform version
    }
  }

  backend "s3" {
    bucket         = "pa1-remote-state-dev"
    key            = "databases"
    region         = "us-east-1"
    dynamodb_table = "pa1-locking-dev"
  }
}

provider "aws" {
  region = "us-east-1"
}