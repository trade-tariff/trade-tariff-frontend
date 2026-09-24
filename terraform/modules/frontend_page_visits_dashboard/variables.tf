terraform {
  required_version = ">= 1.7"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5"
    }
  }
}

variable "environment" {
  description = "Environment containing the frontend request logs."
  type        = string
}

variable "region" {
  description = "AWS region containing the frontend request logs."
  type        = string
}
