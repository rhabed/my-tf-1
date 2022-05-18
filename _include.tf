terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.61.0"
    }
  }
  backend "s3" {
    bucket = "my-rha-tf-state-bucket"
    key    = "tf-state-ec2-host"
    region = "ap-southeast-2"
  }
}

provider "aws" {
  region = var.region
}
