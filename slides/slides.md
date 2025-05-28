---
theme: default
title: From Localhost to AWS
subtitle: Deploying a Containerized Website with Terraform
layout: cover
background: https://cover.sli.dev
class: text-left
transition: slide-left
---

# From Localhost to AWS

Deploying a Containerized Website with Terraform

---

# Agenda

* Introduction
* Local Development and Dockerization
* Pushing Docker Image to Amazon ECR
* Provisioning Infrastructure with Terraform
* Deploying Application on AWS
* Setting Up GitHub Actions for CI/CD
* Integrating AWS CloudWatch for Monitoring
* Conclusion and Q&A

---

# Introduction

Moving a website from your local machine to the cloud doesn't have to be complex. In this talk, we'll walk through a straightforward process to package a website into a Docker container, upload it to AWS, and run it using AWS Server-less services. We'll use Terraform to automate the setup of all necessary AWS resources, including networking, security, and load balancing. By the end of this session, you'll have a clear understanding of how to deploy your own containerized applications to AWS efficiently and reliably.

---
layout: full
class: flex items-center justify-center
---

# AWS Architecture Overview

<div class="diagram-container">
  <img
    src="/aws_containerized_website_deployment.png"
    alt="AWS Architecture"
  />
</div>

---
layout: two-cols
---

# Local Development and Dockerization

## Develop Your Application
- Create a simple web application using your preferred stack
- Ensure the application runs correctly on your local machine

::right::

```bash
# Install dependencies
npm install

# Run the development server
npm run dev
```

## Dockerize the Application

```dockerfile
FROM node:18-alpine AS base
WORKDIR /app
COPY . .
RUN npm ci && npm run build
EXPOSE 3000
CMD ["npm", "start"]
```

---
layout: two-cols
---

# Pushing Docker Image to Amazon ECR

## Create an ECR Repository

```bash
aws ecr create-repository \
  --repository-name my-app
```

## Authenticate Docker to ECR

```bash
aws ecr get-login-password \
  --region us-east-1 | \
  docker login --username AWS \
  --password-stdin \
  123456789012.dkr.ecr.us-east-1.amazonaws.com
```

::right::

## Tag and Push the Docker Image

```bash
# Tag the image
docker tag my-app:latest \
  123456789012.dkr.ecr.us-east-1.amazonaws.com/my-app:latest

# Push the image
docker push \
  123456789012.dkr.ecr.us-east-1.amazonaws.com/my-app:latest
```

---
layout: two-cols
---

# Provisioning Infrastructure with Terraform

## Set Up Terraform Configuration

Define your AWS infrastructure in Terraform files:

- VPC and Subnets
- Security Groups
- ECS Cluster and Task Definitions
- Application Load Balancer
- IAM Roles

::right::

```hcl
# Create ECR Repository
resource "aws_ecr_repository" "app_repo" {
  name = "my-app"
}

# Create ECS Cluster
resource "aws_ecs_cluster" "app_cluster" {
  name = "my-app-cluster"
}
```

---

# Terraform ECS Task Definition

```hcl
resource "aws_ecs_task_definition" "app_task" {
  family                   = "my-app"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"

  container_definitions = jsonencode([{
    name      = "my-app"
    image     = "${aws_ecr_repository.app_repo.repository_url}:latest"
    essential = true
    portMappings = [{
      containerPort = 3000
      hostPort      = 3000
    }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = "/ecs/my-app"
        "awslogs-region"        = "us-east-1"
        "awslogs-stream-prefix" = "ecs"
      }
    }
  }])
}
```

---

# Provisioning Infrastructure with Terraform (continued)

## Initialize and Apply Terraform

```bash
# Initialize Terraform with AWS provider
terraform init

# Preview the changes
terraform plan

# Apply the infrastructure changes
terraform apply
```

This creates all the required AWS resources for running your containerized application.

---
layout: image-right
image: https://source.unsplash.com/collection/94734566/1920x1080
---

# Deploying Application on AWS

## Access the Application

- Retrieve the DNS name of the Application Load Balancer:

```bash
aws elbv2 describe-load-balancers \
  --names my-app-alb \
  --query 'LoadBalancers[0].DNSName' \
  --output text
```

- Navigate to the DNS name in your browser to verify the application is running

---
layout: two-cols
---

# Setting Up GitHub Actions for CI/CD

## Create GitHub Actions Workflow

Create a `.github/workflows/deploy.yml` file:

```yaml
name: Deploy to AWS ECS

on:
  push:
    branches: [main]
```

::right::

```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2

      - uses: aws-actions/configure-aws-credentials@v1
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1
```

---

# GitHub Actions Workflow (continued)

```yaml
      - uses: aws-actions/amazon-ecr-login@v1
        id: login-ecr

      - name: Build and push Docker image
        env:
          ECR_REGISTRY: ${{ steps.login-ecr.outputs.registry }}
          ECR_REPOSITORY: my-app
          IMAGE_TAG: ${{ github.sha }}
        run: |
          docker build -t $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG .
          docker tag $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG $ECR_REGISTRY/$ECR_REPOSITORY:latest
          docker push $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG
          docker push $ECR_REGISTRY/$ECR_REPOSITORY:latest

      - name: Deploy to ECS
        run: |
          aws ecs update-service --cluster my-app-cluster --service my-app-service --force-new-deployment
```

---
layout: two-cols
---

# CloudWatch for Monitoring

## Enable CloudWatch Logs for ECS

In your ECS Task Definition:

```json
"logConfiguration": {
  "logDriver": "awslogs",
  "options": {
    "awslogs-group": "/ecs/my-app",
    "awslogs-region": "us-east-1",
    "awslogs-stream-prefix": "ecs"
  }
}
```

::right::

## Create CloudWatch Alarms

```bash
aws cloudwatch put-metric-alarm \
  --alarm-name high-cpu-utilization \
  --comparison-operator GreaterThanThreshold \
  --evaluation-periods 1 \
  --metric-name CPUUtilization \
  --namespace AWS/ECS \
  --period 300 \
  --statistic Average \
  --threshold 70 \
  --alarm-actions arn:aws:sns:us-east-1:123456789012:alerts
```

---
layout: center
class: text-center
---

# Conclusion and Q&A

- We've walked through deploying a containerized application from local development to AWS using Docker, ECR, ECS, Terraform, GitHub Actions, and CloudWatch.
- This setup provides a scalable, automated, and observable infrastructure for your applications.
- Thank you for your attention! I'm happy to answer any questions.

---
