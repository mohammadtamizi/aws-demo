#!/bin/bash

# Exit on error
set -e

# Set variables
AWS_REGION="us-east-1"
TF_STATE_BUCKET_DEV="aws-demo-terraform-state-dev"
TF_STATE_BUCKET_PROD="aws-demo-terraform-state-prod"

# Get environment to destroy
echo "Which environment do you want to destroy? (dev/prod)"
read ENVIRONMENT

if [ "$ENVIRONMENT" == "dev" ]; then
  STATE_BUCKET=$TF_STATE_BUCKET_DEV
  APP_NAME="aws-demo-dev"
elif [ "$ENVIRONMENT" == "prod" ]; then
  STATE_BUCKET=$TF_STATE_BUCKET_PROD
  APP_NAME="aws-demo"
else
  echo "Invalid environment. Please specify 'dev' or 'prod'."
  exit 1
fi

# Configure AWS credentials if needed
if ! aws sts get-caller-identity &>/dev/null; then
  echo "AWS CLI not configured. Please provide your AWS credentials:"
  echo "AWS Access Key ID:"
  read AWS_ACCESS_KEY_ID
  echo "AWS Secret Access Key:"
  read -s AWS_SECRET_ACCESS_KEY
  
  export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
  export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
  export AWS_REGION=$AWS_REGION
fi

echo "=== Destroying AWS resources for $ENVIRONMENT environment ==="

# Initialize Terraform with the remote state
cd terraform
echo "Initializing Terraform with remote state from S3 bucket: $STATE_BUCKET"
terraform init \
  -backend-config="bucket=$STATE_BUCKET" \
  -backend-config="key=terraform.tfstate" \
  -backend-config="region=$AWS_REGION"

# Set a default container image
CONTAINER_IMAGE="amazon/amazon-ecs-sample:latest"

# Run Terraform destroy
echo "Running Terraform destroy..."
terraform destroy -auto-approve \
  -var="aws_region=$AWS_REGION" \
  -var="app_image=$CONTAINER_IMAGE" \
  -var="app_name=$APP_NAME" \
  -var="environment=$ENVIRONMENT"

echo "=== Destroy complete ==="

# Optionally, confirm resources are gone
echo "Checking if ECS cluster still exists..."
if aws ecs describe-clusters --clusters "${APP_NAME}-cluster" --query 'clusters[0].status' --output text 2>/dev/null; then
  echo "WARNING: ECS cluster still exists. Some resources may not have been properly destroyed."
else
  echo "✅ ECS cluster successfully destroyed."
fi

echo "Checking if ECR repository still exists..."
if aws ecr describe-repositories --repository-names "${APP_NAME}-repo" --query 'repositories[0].repositoryName' --output text 2>/dev/null; then
  echo "WARNING: ECR repository still exists. You may want to delete it manually."
else
  echo "✅ ECR repository successfully destroyed."
fi

echo "All done! If any warnings appeared above, you may need to manually clean up some resources." 