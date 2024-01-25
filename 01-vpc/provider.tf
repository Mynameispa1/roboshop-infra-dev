provider "aws" {
    region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "pavan-remote-state"
    key    = "vpc"
    region = "us-east-1"
    dynamodb_table = "pavan-locking-dev"
  }
}