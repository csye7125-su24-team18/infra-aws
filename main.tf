terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 0.12"
}

provider "aws" {
  profile = "dev" //Need to change this to your profile name
  region  = var.region
}

# Provider for Infra account
provider "aws" {
  alias   = "infra"
  region  = "us-east-1"
  profile = "infra" # Assuming you use named profiles; adjust as needed
}


resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/eks/dev-cluster/cluster"
  retention_in_days = 7

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [name]
  }
}
