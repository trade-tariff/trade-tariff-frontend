terraform {
  required_version = ">=1.9.8"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4"
    }
  }

  backend "s3" {}
}

provider "aws" {}
