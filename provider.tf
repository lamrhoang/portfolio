terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.10.0"
    }
  }
}

provider "aws" {
  region = "us-west-1"
}

provider "aws" {
  alias  = "acm_provider"
  region = "us-east-1"
}