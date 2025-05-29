variable "aws_region" {
  description = "The AWS region to deploy resources into"
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "The name of the application"
  type        = string
  default     = "aws-demo"
}

variable "app_image" {
  description = "The Docker image to deploy (URL with tag)"
  type        = string
  default     = "amazon/amazon-ecs-sample:latest"
}

variable "app_count" {
  description = "Number of instances of the application to run"
  type        = number
  default     = 1
}

variable "availability_zones" {
  description = "List of availability zones to use for the subnets in the VPC"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "container_cpu" {
  description = "The amount of CPU to allocate to the container"
  type        = number
  default     = 256
}

variable "container_memory" {
  description = "The amount of memory to allocate to the container"
  type        = number
  default     = 512
}

variable "convex_url_parameter_arn" {
  description = "The ARN of the SSM Parameter Store parameter containing the Convex URL"
  type        = string
}

variable "environment" {
  description = "The environment (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "acm_certificate_arn" {
  description = "The ARN of the ACM certificate to use for HTTPS"
  type        = string
  default     = ""
}

variable "domain_name" {
  description = "The domain name to use for the application"
  type        = string
  default     = ""
}
