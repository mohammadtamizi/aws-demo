#!/bin/bash
set -e

# Colors for better output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Variables
REGION="us-east-1"

# Check required tools
check_command() {
  if ! command -v $1 &> /dev/null; then
    echo -e "${RED}Error: $1 is required but not installed.${NC}"
    exit 1
  fi
}

# Check required commands
echo -e "${GREEN}Checking required tools...${NC}"
check_command "terraform"
check_command "aws"
check_command "jq"

# Check AWS credentials
echo -e "${GREEN}Checking AWS credentials...${NC}"
if ! aws sts get-caller-identity &> /dev/null; then
  echo -e "${RED}Error: AWS credentials not found or invalid.${NC}"
  echo -e "Please run 'aws configure' to set up your AWS credentials."
  exit 1
fi

echo -e "${YELLOW}Starting cleanup process...${NC}"

# Check if terraform directory exists
if [ ! -d "terraform" ]; then
  echo -e "${RED}Error: terraform directory not found!${NC}"
  exit 1
fi

# Change to terraform directory
cd terraform

# Get important resource info before deletion for verification
echo -e "${GREEN}Step 1: Collecting resource information...${NC}"

if terraform output -json > /tmp/tf_output.json 2>/dev/null; then
  ECR_REPO_URL=$(jq -r '.ecr_repository_url.value // empty' /tmp/tf_output.json)
  EC2_IP=$(jq -r '.ec2_public_ip.value // empty' /tmp/tf_output.json)
  EC2_INSTANCE_ID=$(jq -r '.ec2_instance_id.value // empty' /tmp/tf_output.json)
  
  if [ -n "$ECR_REPO_URL" ]; then
    echo -e "ECR Repository URL: ${YELLOW}$ECR_REPO_URL${NC}"
  fi
  
  if [ -n "$EC2_IP" ]; then
    echo -e "EC2 Instance Public IP: ${YELLOW}$EC2_IP${NC} (temporary, will be released automatically)"
  fi
  
  if [ -n "$EC2_INSTANCE_ID" ]; then
    echo -e "EC2 Instance ID: ${YELLOW}$EC2_INSTANCE_ID${NC}"
  fi
else
  echo -e "${YELLOW}No existing Terraform state found or outputs available.${NC}"
fi

# Step 2: Remove all Docker images from ECR repository before destroying
if [ -n "$ECR_REPO_URL" ]; then
  echo -e "${GREEN}Step 2: Cleaning up ECR repository images...${NC}"
  
  # Extract repository name from URL
  REPO_NAME=$(echo $ECR_REPO_URL | cut -d'/' -f2)
  
  echo -e "Deleting images from repository: ${YELLOW}$REPO_NAME${NC}"
  
  # Force delete images (if any)
  aws ecr batch-delete-image --repository-name $REPO_NAME --region $REGION \
    --image-ids "$(aws ecr list-images --repository-name $REPO_NAME --region $REGION \
    --query 'imageIds[*]' --output json)" || echo -e "${YELLOW}No images to delete or repository doesn't exist.${NC}"
fi

# Step 3: Check if we need to stop EC2 instance first
if [ -n "$EC2_INSTANCE_ID" ]; then
  echo -e "${GREEN}Step 3: Stopping EC2 instance ${YELLOW}$EC2_INSTANCE_ID${NC} before cleanup...${NC}"
  
  # Check if instance exists and is running
  INSTANCE_STATE=$(aws ec2 describe-instances --instance-ids $EC2_INSTANCE_ID --region $REGION \
    --query 'Reservations[0].Instances[0].State.Name' --output text 2>/dev/null || echo "not-found")
  
  if [ "$INSTANCE_STATE" != "not-found" ] && [ "$INSTANCE_STATE" != "terminated" ]; then
    echo -e "Instance state: ${YELLOW}$INSTANCE_STATE${NC}"
    
    if [ "$INSTANCE_STATE" != "stopped" ]; then
      echo -e "Stopping instance ${YELLOW}$EC2_INSTANCE_ID${NC}..."
      aws ec2 stop-instances --instance-ids $EC2_INSTANCE_ID --region $REGION
      
      echo -e "Waiting for instance to stop..."
      aws ec2 wait instance-stopped --instance-ids $EC2_INSTANCE_ID --region $REGION
    fi
  else
    echo -e "${YELLOW}Instance not found or already terminated.${NC}"
  fi
fi

# Step 4: Destroy all resources with Terraform
echo -e "${GREEN}Step 4: Destroying all AWS resources with Terraform...${NC}"
echo -e "${RED}This will permanently delete ALL resources created by Terraform.${NC}"
read -p "Are you sure you want to continue? (y/n) " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
  echo -e "Proceeding with terraform destroy..."
  terraform destroy -auto-approve

  # Verify destruction
  echo -e "${GREEN}Step 5: Verifying resource cleanup...${NC}"
  
  # Check if EC2 instance still exists
  if [ -n "$EC2_INSTANCE_ID" ]; then
    INSTANCE_STATE=$(aws ec2 describe-instances --instance-ids $EC2_INSTANCE_ID --region $REGION \
      --query 'Reservations[0].Instances[0].State.Name' --output text 2>/dev/null || echo "not-found")
    
    if [ "$INSTANCE_STATE" != "not-found" ] && [ "$INSTANCE_STATE" != "terminated" ]; then
      echo -e "${YELLOW}Warning: EC2 instance ${RED}$EC2_INSTANCE_ID${YELLOW} still exists in state: ${RED}$INSTANCE_STATE${NC}"
      echo -e "You may need to manually delete this instance from the AWS console."
    else
      echo -e "EC2 instance ${GREEN}successfully terminated${NC}"
    fi
  fi
  
  # Check if ECR repository still exists
  if [ -n "$ECR_REPO_URL" ]; then
    REPO_NAME=$(echo $ECR_REPO_URL | cut -d'/' -f2)
    if aws ecr describe-repositories --repository-names $REPO_NAME --region $REGION &>/dev/null; then
      echo -e "${YELLOW}Warning: ECR repository ${RED}$REPO_NAME${YELLOW} still exists.${NC}"
      echo -e "You may need to manually delete this repository from the AWS console."
    else
      echo -e "ECR repository ${GREEN}successfully deleted${NC}"
    fi
  fi
  
  # Final cleanup
  echo -e "${GREEN}Cleanup completed!${NC}"
  echo -e "All AWS resources should now be destroyed. If any warnings were shown above, please check the AWS console."
else
  echo -e "${YELLOW}Cleanup cancelled by user.${NC}"
fi 