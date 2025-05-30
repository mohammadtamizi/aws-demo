output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.app_instance.id
}

output "public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.app_instance.public_ip
}

# No longer using Elastic IP
# output "elastic_ip" {
#   description = "Elastic IP allocated to the EC2 instance"
#   value       = aws_eip.app_eip.public_ip
# }

output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.app_vpc.id
}

output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = aws_subnet.public_subnet.id
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.app_sg.id
} 