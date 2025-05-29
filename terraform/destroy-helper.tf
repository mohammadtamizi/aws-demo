/*
 * This file contains a workaround for the common Terraform destroy problem with AWS resources.
 * It includes null resources that use local-exec provisioners to help clean up resources
 * that might get stuck during the destroy phase due to dependencies not being properly released.
 */

# This resource can be manually triggered with: terraform apply -target=null_resource.cleanup_ecs_resources
resource "null_resource" "cleanup_ecs_resources" {
  # Only create this resource when explicitly targeted
  count = 0

  # This will only run when explicitly targeted
  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
      # Get list of running tasks
      TASKS=$(aws ecs list-tasks --cluster ${aws_ecs_cluster.main.name} --region ${var.aws_region} --query 'taskArns[]' --output text)

      # Stop each task
      for TASK in $TASKS; do
        echo "Stopping task $TASK"
        aws ecs stop-task --cluster ${aws_ecs_cluster.main.name} --task $TASK --region ${var.aws_region}
      done

      # Wait for tasks to stop
      echo "Waiting for tasks to stop..."
      sleep 30

      # Update service desired count to 0
      echo "Setting service desired count to 0"
      aws ecs update-service --cluster ${aws_ecs_cluster.main.name} --service ${aws_ecs_service.app.name} --desired-count 0 --region ${var.aws_region}

      echo "ECS resources cleanup completed"
    EOT
  }

  depends_on = [aws_ecs_service.app]
}

# This resource can be manually triggered with: terraform apply -target=null_resource.cleanup_network_interfaces
resource "null_resource" "cleanup_network_interfaces" {
  # Only create this resource when explicitly targeted
  count = 0

  # This will only run when explicitly targeted
  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
      # Find ENIs associated with the security group
      SG_ID=${aws_security_group.ecs_tasks.id}
      echo "Looking for network interfaces associated with security group $SG_ID"

      ENIs=$(aws ec2 describe-network-interfaces --filters "Name=group-id,Values=$SG_ID" --query 'NetworkInterfaces[*].NetworkInterfaceId' --output text --region ${var.aws_region})

      # Detach and delete each ENI
      for ENI in $ENIs; do
        echo "Detaching and deleting network interface $ENI"
        ATTACHMENT=$(aws ec2 describe-network-interfaces --network-interface-ids $ENI --query 'NetworkInterfaces[0].Attachment.AttachmentId' --output text --region ${var.aws_region})

        if [ "$ATTACHMENT" != "None" ] && [ "$ATTACHMENT" != "null" ]; then
          echo "Detaching attachment $ATTACHMENT"
          aws ec2 detach-network-interface --attachment-id $ATTACHMENT --force --region ${var.aws_region}
          # Wait for detachment to complete
          sleep 15
        fi

        echo "Deleting network interface $ENI"
        aws ec2 delete-network-interface --network-interface-id $ENI --region ${var.aws_region}
      done

      echo "Network interfaces cleanup completed"
    EOT
  }

  depends_on = [null_resource.cleanup_ecs_resources]
}

# This block provides instructions for manual cleanup
output "cleanup_instructions" {
  value = <<-EOT
    If Terraform destroy gets stuck, run these commands in sequence:

    1. Cleanup ECS resources first:
       terraform apply -target=null_resource.cleanup_ecs_resources

    2. Then cleanup network interfaces:
       terraform apply -target=null_resource.cleanup_network_interfaces

    3. Finally try destroy again:
       terraform destroy

    For manual cleanup in AWS Console:
    - Check ECS cluster for running tasks and services
    - Check EC2 > Network Interfaces for any ENIs using your security groups
    - Check VPC > Subnets for any resources still in the subnets
  EOT
}
