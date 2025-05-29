output "ecr_repository_url" {
  description = "The URL of the ECR repository"
  value       = aws_ecr_repository.app_repo.repository_url
}

output "ecs_cluster_name" {
  description = "The name of the ECS cluster"
  value       = aws_ecs_cluster.main.name
}

output "ecs_service_name" {
  description = "The name of the ECS service"
  value       = aws_ecs_service.app.name
}

output "task_access_instructions" {
  description = "Instructions to access the running task"
  value       = "Find the public IP in the AWS Console: ECS > Clusters > ${aws_ecs_cluster.main.name} > Service ${aws_ecs_service.app.name} > Tasks tab > Network > Public IP"
}

output "cloudwatch_log_group" {
  description = "The name of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.app.name
}
