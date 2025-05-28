terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # The S3 backend is configured dynamically during 'terraform init' in the CI/CD pipeline
  # using the -backend-config options
  backend "s3" {
    region = "us-east-1"
    bucket = "aws-demo-terraform-state-${var.environment}"
  }
}
