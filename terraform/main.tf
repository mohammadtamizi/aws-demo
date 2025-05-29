provider "aws" {
  region = var.aws_region
}

# ============================================
# COST-OPTIMIZED CONFIGURATION FOR DEMO/DEV
# ============================================
# The following configuration has been optimized to minimize AWS costs:
# 1. Uses only ONE availability zone instead of multiple
# 2. Eliminates NAT Gateways (one of the most expensive resources)
# 3. Places ECS tasks in public subnets with public IPs
# 4. Limits auto-scaling resources
# ============================================

# ECR Repository
resource "aws_ecr_repository" "app_repo" {
  name                 = "${var.app_name}-repo"
  image_tag_mutability = "MUTABLE"
}

# Configure ECR Registry Scanning (replacing deprecated repository-level scanning)
resource "aws_ecr_registry_scanning_configuration" "example" {
  scan_type = "ENHANCED" # Use enhanced scanning for better vulnerability detection

  rule {
    scan_frequency = "SCAN_ON_PUSH"
    repository_filter {
      filter      = "${var.app_name}-repo"
      filter_type = "WILDCARD"
    }
  }

  # Additional rule for periodic scanning of all repositories as a fallback
  rule {
    scan_frequency = "CONTINUOUS_SCAN"
    repository_filter {
      filter      = "*"
      filter_type = "WILDCARD"
    }
  }
}

# VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.app_name}-vpc"
  }
}

# Public Subnet - COST SAVING: Using only one AZ instead of multiple
resource "aws_subnet" "public" {
  # COST SAVING: Using only first AZ instead of multiple
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = var.availability_zones[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.app_name}-public-subnet-1"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.app_name}-igw"
  }
}

# COST SAVING: NAT Gateway and Elastic IP resources have been removed
# NAT Gateways are expensive (~$32/month each) and not needed for demo environments
# where we can place ECS tasks in public subnets

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.app_name}-public-rt"
  }
}

# Public Route Table Association
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# COST SAVING: Private subnets, NAT Gateway, and private route tables have been removed

# Security Group for ECS Tasks
resource "aws_security_group" "ecs_tasks" {
  name        = "${var.app_name}-ecs-tasks-sg"
  description = "Security group for ECS tasks"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.app_name}-ecs-tasks-sg"
  }
}

# ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "${var.app_name}-cluster"

  # COST SAVING: Disable Container Insights to save on CloudWatch costs
  setting {
    name  = "containerInsights"
    value = "disabled"
  }

  tags = {
    Name = "${var.app_name}-cluster"
  }
}

# ECS Task Execution Role
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.app_name}-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.app_name}-ecs-task-execution-role"
  }
}

# Create a more restrictive policy instead of using the managed policy
resource "aws_iam_policy" "ecs_task_execution_policy" {
  name        = "${var.app_name}-ecs-task-execution-policy"
  description = "Custom policy for ECS task execution with least privilege"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "${aws_cloudwatch_log_group.app.arn}:*"
      },
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameters"
        ]
        Resource = [
          var.convex_url_parameter_arn
        ]
      }
    ]
  })
}

# Attach custom policy instead of managed policy
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.ecs_task_execution_policy.arn
}

# CloudWatch Log Group - COST SAVING: Reducing log retention to 7 days
resource "aws_cloudwatch_log_group" "app" {
  name              = "/ecs/${var.app_name}"
  retention_in_days = 7  # Reduced from 30 days to save on CloudWatch costs

  tags = {
    Name = "${var.app_name}-log-group"
  }
}

# ECS Task Definition
resource "aws_ecs_task_definition" "app" {
  family                   = var.app_name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  # COST SAVING: Using minimum viable CPU and memory
  cpu                      = var.container_cpu
  memory                   = var.container_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = var.app_name
      image     = var.app_image
      essential = true

      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "NODE_ENV"
          value = "production"
        }
      ]

      secrets = [
        {
          name      = "NEXT_PUBLIC_CONVEX_URL"
          valueFrom = var.convex_url_parameter_arn
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.app.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])

  tags = {
    Name = "${var.app_name}-task-definition"
  }
}

# ECS Service - COST SAVING: Using public subnet and assigning public IP
resource "aws_ecs_service" "app" {
  name                              = "${var.app_name}-service"
  cluster                           = aws_ecs_cluster.main.id
  task_definition                   = aws_ecs_task_definition.app.arn
  desired_count                     = 1  # COST SAVING: Using only 1 task
  launch_type                       = "FARGATE"
  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent        = 200

  network_configuration {
    security_groups  = [aws_security_group.ecs_tasks.id]
    # COST SAVING: Using public subnet instead of private subnet to avoid NAT Gateway
    subnets          = [aws_subnet.public.id]
    # COST SAVING: Assigning public IP so tasks can access internet directly
    assign_public_ip = true
  }

  tags = {
    Name = "${var.app_name}-service"
  }
}

# COST SAVING: Auto Scaling resources commented out for demo environment
# Uncomment for production use
# # Auto Scaling for ECS
# resource "aws_appautoscaling_target" "ecs_target" {
#   max_capacity       = 5
#   min_capacity       = 1
#   resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.app.name}"
#   scalable_dimension = "ecs:service:DesiredCount"
#   service_namespace  = "ecs"
# }
#
# # Auto Scaling Policy - CPU
# resource "aws_appautoscaling_policy" "ecs_policy_cpu" {
#   name               = "${var.app_name}-cpu-autoscaling"
#   policy_type        = "TargetTrackingScaling"
#   resource_id        = aws_appautoscaling_target.ecs_target.resource_id
#   scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
#   service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace
#
#   target_tracking_scaling_policy_configuration {
#     predefined_metric_specification {
#       predefined_metric_type = "ECSServiceAverageCPUUtilization"
#     }
#     target_value       = 70
#     scale_in_cooldown  = 300
#     scale_out_cooldown = 300
#   }
# }
#
# # Auto Scaling Policy - Memory
# resource "aws_appautoscaling_policy" "ecs_policy_memory" {
#   name               = "${var.app_name}-memory-autoscaling"
#   policy_type        = "TargetTrackingScaling"
#   resource_id        = aws_appautoscaling_target.ecs_target.resource_id
#   scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
#   service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace
#
#   target_tracking_scaling_policy_configuration {
#     predefined_metric_specification {
#       predefined_metric_type = "ECSServiceAverageMemoryUtilization"
#     }
#     target_value       = 70
#     scale_in_cooldown  = 300
#     scale_out_cooldown = 300
#   }
# }
