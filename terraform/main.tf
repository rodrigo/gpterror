locals { var = { for key, value in local.dev : key => value } }

terraform {
  backend "s3" {
    bucket = "rebelatto"
    key    = "terraform/state"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    godaddy = {
      source = "n3integration/godaddy"
      version = "~> 1.9.1"
    }
  }
}

data "aws_caller_identity" "current" {}

provider "aws" {
  default_tags {
    tags = {
      Terraform = "true"
    }
  }
}
