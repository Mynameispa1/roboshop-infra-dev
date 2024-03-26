

provider "aws" {
    region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "pa1-remote-state"
    key    = "vpc"
    region = "us-east-1"
    dynamodb_table = "pa1-locking-dev"
  }
}

