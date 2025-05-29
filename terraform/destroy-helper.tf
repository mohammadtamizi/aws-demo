/*
 * This file contains outputs and guidance to help with cleaning up AWS resources
 * that might get stuck during terraform destroy.
 */

# Output the necessary resource IDs and names for manual cleanup
output "cleanup_ecs_cluster_name" {
  description = "The name of the ECS cluster for cleanup"
  value       = aws_ecs_cluster.main.name
}

output "cleanup_ecs_service_name" {
  description = "The name of the ECS service for cleanup"
  value       = aws_ecs_service.app.name
}

output "cleanup_security_group_id" {
  description = "The ID of the security group used by ECS tasks for cleanup"
  value       = aws_security_group.ecs_tasks.id
}

output "cleanup_vpc_id" {
  description = "The ID of the VPC for cleanup"
  value       = aws_vpc.main.id
}

output "cleanup_subnet_id" {
  description = "The ID of the public subnet for cleanup"
  value       = aws_subnet.public.id
}

# Create a local file with cleanup instructions and commands
resource "local_file" "cleanup_script" {
  filename = "${path.module}/aws-cleanup.sh"
  content  = <<-EOT
#!/bin/bash
# AWS Resource Cleanup Script
# This script helps clean up AWS resources that might be stuck during terraform destroy

# Usage: ./aws-cleanup.sh [aws-region]
# Example: ./aws-cleanup.sh us-east-1

# Set the AWS region
AWS_REGION=$${1:-"us-east-1"}
echo "Using AWS region: $$AWS_REGION"

# Output resource identifiers
echo "ECS Cluster: ${aws_ecs_cluster.main.name}"
echo "ECS Service: ${aws_ecs_service.app.name}"
echo "Security Group: ${aws_security_group.ecs_tasks.id}"
echo "VPC: ${aws_vpc.main.id}"
echo "Subnet: ${aws_subnet.public.id}"

# Clean up ECS resources
cleanup_ecs() {
  echo "=== Cleaning up ECS resources ==="

  # Get list of running tasks
  echo "Finding running tasks..."
  TASKS=$$(aws ecs list-tasks --cluster ${aws_ecs_cluster.main.name} --region $$AWS_REGION --query 'taskArns[]' --output text)

  # Stop each task
  if [ -n "$$TASKS" ]; then
    for TASK in $$TASKS; do
      echo "Stopping task $$TASK"
      aws ecs stop-task --cluster ${aws_ecs_cluster.main.name} --task $$TASK --region $$AWS_REGION
    done

    # Wait for tasks to stop
    echo "Waiting for tasks to stop..."
    sleep 30
  else
    echo "No running tasks found."
  fi

  # Update service desired count to 0
  echo "Setting service desired count to 0"
  aws ecs update-service --cluster ${aws_ecs_cluster.main.name} --service ${aws_ecs_service.app.name} --desired-count 0 --region $$AWS_REGION

  echo "ECS resources cleanup completed"
}

# Clean up network interfaces
cleanup_network_interfaces() {
  echo "=== Cleaning up network interfaces ==="

  # Find ENIs associated with the security group
  SG_ID=${aws_security_group.ecs_tasks.id}
  echo "Looking for network interfaces associated with security group $$SG_ID"

  ENIs=$$(aws ec2 describe-network-interfaces --filters "Name=group-id,Values=$$SG_ID" --query 'NetworkInterfaces[*].NetworkInterfaceId' --output text --region $$AWS_REGION)

  # Detach and delete each ENI
  if [ -n "$$ENIs" ]; then
    for ENI in $$ENIs; do
      echo "Found network interface $$ENI"
      ATTACHMENT=$$(aws ec2 describe-network-interfaces --network-interface-ids $$ENI --query 'NetworkInterfaces[0].Attachment.AttachmentId' --output text --region $$AWS_REGION)

      if [ "$$ATTACHMENT" != "None" ] && [ "$$ATTACHMENT" != "null" ]; then
        echo "Detaching attachment $$ATTACHMENT"
        aws ec2 detach-network-interface --attachment-id $$ATTACHMENT --force --region $$AWS_REGION
        # Wait for detachment to complete
        sleep 15
      fi

      echo "Deleting network interface $$ENI"
      aws ec2 delete-network-interface --network-interface-id $$ENI --region $$AWS_REGION
    done
  else
    echo "No network interfaces found with the specified security group."
  fi

  echo "Network interfaces cleanup completed"
}

# Clean up subnet dependencies
cleanup_subnet_dependencies() {
  echo "=== Checking for subnet dependencies ==="

  SUBNET_ID=${aws_subnet.public.id}
  echo "Looking for resources in subnet $$SUBNET_ID"

  # List resources in the subnet
  INSTANCES=$$(aws ec2 describe-instances --filters "Name=subnet-id,Values=$$SUBNET_ID" --query 'Reservations[].Instances[].InstanceId' --output text --region $$AWS_REGION)
  if [ -n "$$INSTANCES" ]; then
    echo "WARNING: Found EC2 instances in subnet: $$INSTANCES"
    echo "You may need to terminate these instances manually."
  fi

  ENIs=$$(aws ec2 describe-network-interfaces --filters "Name=subnet-id,Values=$$SUBNET_ID" --query 'NetworkInterfaces[*].NetworkInterfaceId' --output text --region $$AWS_REGION)
  if [ -n "$$ENIs" ]; then
    echo "Found network interfaces in subnet: $$ENIs"
    echo "These may need to be detached and deleted."
  fi

  echo "Subnet dependencies check completed"
}

# Main cleanup sequence
main() {
  echo "Starting AWS cleanup process..."

  # Run the cleanup functions in sequence
  cleanup_ecs
  cleanup_network_interfaces
  cleanup_subnet_dependencies

  echo "Cleanup process completed. You can now try 'terraform destroy' again."
  echo "If destroy still fails, check the AWS Console for any remaining resources."
}

# Run the main function
main
EOT

  # Make the script executable
  provisioner "local-exec" {
    command = "chmod +x ${path.module}/aws-cleanup.sh"
  }
}

# This output provides clear instructions for manual cleanup
output "cleanup_instructions" {
  value = <<-EOT
    If Terraform destroy gets stuck, follow these steps:

    1. Run the generated cleanup script:
       ./terraform/aws-cleanup.sh [aws-region]

       For example:
       ./terraform/aws-cleanup.sh us-east-1

    2. After the script completes, try terraform destroy again:
       terraform destroy

    For manual cleanup in AWS Console:
    - ECS: Check cluster "${aws_ecs_cluster.main.name}" for running tasks and service "${aws_ecs_service.app.name}"
    - EC2: Check Network Interfaces for any ENIs using security group "${aws_security_group.ecs_tasks.id}"
    - VPC: Check subnet "${aws_subnet.public.id}" for any resources still attached
  EOT
}
