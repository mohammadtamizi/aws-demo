output "ecr_repository_url" {
  description = "URL of the ECR repository"
  value       = module.ecr.repository_url
}

output "ecr_repository_name" {
  description = "Name of the ECR repository"
  value       = module.ecr.repository_name
}

output "ec2_instance_id" {
  description = "ID of the EC2 instance"
  value       = module.ec2.instance_id
}

output "ec2_public_ip" {
  description = "Public IP address of the EC2 instance (temporary)"
  value       = module.ec2.public_ip
}

# No longer using Elastic IP to avoid costs
# output "ec2_elastic_ip" {
#   description = "Elastic IP allocated to the EC2 instance"
#   value       = module.ec2.elastic_ip
# }

output "app_url" {
  description = "URL to access the application"
  value       = "http://${module.ec2.public_ip}"
} 