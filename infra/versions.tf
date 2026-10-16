terraform {
  required_version = ">= 1.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  # Production: remote state with locking (kept commented so the snippet validates offline)
  # backend "s3" {
  #   bucket       = "mf-india-tfstate"
  #   key          = "ml-platform/chart-registry.tfstate"
  #   region       = "ap-south-1"
  #   use_lockfile = true
  # }
}

provider "aws" {
  region = var.region
}