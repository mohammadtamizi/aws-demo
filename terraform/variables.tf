variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "aws-demo"
}

variable "app_port" {
  description = "Port that the application runs on"
  type        = number
  default     = 3000
}

variable "instance_type" {
  description = "EC2 instance type (must be in Free Tier)"
  type        = string
  default     = "t2.micro"
}

variable "ssh_cidr_block" {
  description = "CIDR block for SSH access to EC2 instance"
  type        = string
  default     = "0.0.0.0/0"  # This is wide open - restrict to your IP in production
}

variable "public_key_path" {
  description = "Path to public key for EC2 SSH access"
  type        = string
  default     = "~/.ssh/id_rsa.pub"  # Use generic path that can be expanded by Terraform
  sensitive   = true
}

variable "convex_url" {
  description = "URL for the Convex backend"
  type        = string
  default     = "NEXT_PUBLIC_CONVEX_URL_PLACEHOLDER"
} 