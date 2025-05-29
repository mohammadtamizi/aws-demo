#!/bin/bash

# Exit on any error
set -e

echo "==== Testing ECS Deployment with Fixed SSM Parameter ===="
echo ""

# Step 1: Ensure AWS CLI is configured
if ! aws sts get-caller-identity &>/dev/null; then
  echo "Error: AWS CLI is not configured. Please run 'aws configure' first."
  exit 1
fi

echo "✅ AWS CLI is configured"

# Step 2: Check if the SSM parameter exists
if aws ssm get-parameter --name "/convex-url" --with-decryption &>/dev/null; then
  echo "✅ SSM parameter '/convex-url' exists"
else
  echo "Creating SSM parameter '/convex-url'"
  aws ssm put-parameter \
    --name "/convex-url" \
    --type "SecureString" \
    --value "https://your-actual-convex-url.convex.cloud" \
    --overwrite
  echo "✅ SSM parameter created"
fi

# Step 3: Apply Terraform changes (optional - uncomment if needed)
# echo "Applying Terraform changes..."
# cd terraform
# terraform init
# terraform apply -auto-approve
# cd ..
# echo "✅ Terraform applied"

# Step 4: Check ECS service status
echo "Checking ECS service status..."
CLUSTER_EXISTS=$(aws ecs describe-clusters --clusters aws-demo-cluster --query 'clusters[0].status' --output text 2>/dev/null || echo "MISSING")

if [ "$CLUSTER_EXISTS" == "ACTIVE" ]; then
  echo "✅ ECS cluster exists"

  # Check service status
  SERVICE_STATUS=$(aws ecs describe-services --cluster aws-demo-cluster --services aws-demo-service --query 'services[0].status' --output text 2>/dev/null || echo "MISSING")

  if [ "$SERVICE_STATUS" == "ACTIVE" ]; then
    echo "✅ ECS service is active"

    # Check tasks
    RUNNING_TASKS=$(aws ecs list-tasks --cluster aws-demo-cluster --service-name aws-demo-service --desired-status RUNNING --query 'taskArns' --output text)

    if [ -n "$RUNNING_TASKS" ]; then
      echo "✅ ECS tasks are running"
      echo "Task ARNs: $RUNNING_TASKS"
    else
      echo "❌ No running tasks found. Check the task definition."
    fi
  else
    echo "❌ ECS service is not active or doesn't exist"
  fi
else
  echo "❌ ECS cluster doesn't exist yet. Run Terraform to create it."
fi

echo ""
echo "==== Deployment Test Complete ===="
