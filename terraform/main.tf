terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Using local backend instead of S3
  backend "local" {
    path = "terraform.tfstate"
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "aws-demo"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}

# S3 bucket for Terraform state is no longer needed since we're using local backend
# Removing the aws_s3_bucket and related resources

# DynamoDB for state locking is also no longer needed with local backend
# Removing the aws_dynamodb_table resource 