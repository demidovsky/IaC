terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region     = "us-central-1"
  access_key = "ABCD.............XYZ"
  secret_key = "abcd..............................xyz"
}
