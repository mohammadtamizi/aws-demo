#!/bin/bash
set -e

# Colors for better output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Variables
REGION="us-east-1"
PROJECT_NAME="aws-demo"
DOCKER_IMAGE_NAME="aws-demo-local"
DOCKER_IMAGE_TAG="latest"
CONTAINER_NAME="aws-demo-container"

# Get Convex URL from environment variable or use a placeholder
# Production deployments should set this as an environment variable
if [ -z "$NEXT_PUBLIC_CONVEX_URL" ]; then
  echo -e "${YELLOW}Warning: NEXT_PUBLIC_CONVEX_URL environment variable is not set.${NC}"
  echo -e "${YELLOW}Using default placeholder. Set this variable for production deployments.${NC}"
  CONVEX_URL="YOUR_CONVEX_URL_HERE"
else
  CONVEX_URL="$NEXT_PUBLIC_CONVEX_URL"
  echo -e "${GREEN}Using Convex URL from environment variable.${NC}"
fi

# Check required tools
check_command() {
  if ! command -v $1 &> /dev/null; then
    echo -e "${RED}Error: $1 is required but not installed.${NC}"
    exit 1
  fi
}

# Check required commands
echo -e "${GREEN}Checking required tools...${NC}"
check_command "docker"
check_command "terraform"
check_command "aws"

# Check AWS credentials
echo -e "${GREEN}Checking AWS credentials...${NC}"
if ! aws sts get-caller-identity &> /dev/null; then
  echo -e "${RED}Error: AWS credentials not found or invalid.${NC}"
  echo -e "Please run 'aws configure' to set up your AWS credentials."
  exit 1
fi

# Check SSH key exists
if [ ! -f ~/.ssh/id_rsa ]; then
  echo -e "${RED}Error: SSH key not found at ~/.ssh/id_rsa${NC}"
  echo -e "Please create an SSH key pair using 'ssh-keygen -t rsa'"
  exit 1
fi

echo -e "${YELLOW}Starting deployment process...${NC}"

# Step 1: Apply Terraform to create infrastructure
echo -e "${GREEN}Step 1: Building infrastructure with Terraform...${NC}"
cd terraform

terraform init
terraform plan -var "project_name=$PROJECT_NAME" -var "aws_region=$REGION" -var "convex_url=$CONVEX_URL"
terraform apply -auto-approve -var "project_name=$PROJECT_NAME" -var "aws_region=$REGION" -var "convex_url=$CONVEX_URL"

# Get important outputs
ECR_REPO_URL=$(terraform output -raw ecr_repository_url)
EC2_PUBLIC_IP=$(terraform output -raw ec2_public_ip)
EC2_INSTANCE_ID=$(terraform output -raw ec2_instance_id)

echo -e "ECR Repository URL: ${YELLOW}$ECR_REPO_URL${NC}"
echo -e "EC2 Instance Public IP: ${YELLOW}$EC2_PUBLIC_IP${NC}"
echo -e "EC2 Instance ID: ${YELLOW}$EC2_INSTANCE_ID${NC}"

# Move back to the project root
cd ..

# Step 2: Verify Docker image exists or build it
echo -e "${GREEN}Step 2: Preparing Docker image...${NC}"
if docker image inspect $DOCKER_IMAGE_NAME:$DOCKER_IMAGE_TAG > /dev/null 2>&1; then
  echo -e "Docker image ${YELLOW}$DOCKER_IMAGE_NAME:$DOCKER_IMAGE_TAG${NC} already exists."
else
  echo -e "Building Docker image ${YELLOW}$DOCKER_IMAGE_NAME:$DOCKER_IMAGE_TAG${NC}..."
  docker build -t $DOCKER_IMAGE_NAME:$DOCKER_IMAGE_TAG --build-arg NEXT_PUBLIC_CONVEX_URL="$CONVEX_URL" .
fi

# Step 3: Tag and push Docker image to ECR
echo -e "${GREEN}Step 3: Pushing Docker image to ECR...${NC}"
aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ECR_REPO_URL
docker tag $DOCKER_IMAGE_NAME:$DOCKER_IMAGE_TAG $ECR_REPO_URL:$DOCKER_IMAGE_TAG
docker push $ECR_REPO_URL:$DOCKER_IMAGE_TAG

# Step 4: Deploy to EC2
echo -e "${GREEN}Step 4: Deploying application to EC2 instance...${NC}"

# Wait for the instance to be fully initialized
echo -e "Waiting for EC2 instance to be ready..."
sleep 30

# Create temporary ECR token file
aws ecr get-login-password --region $REGION > ecr_token.txt

# Copy the token to EC2
echo -e "Copying ECR token to EC2 instance..."
scp -o StrictHostKeyChecking=no -i ~/.ssh/id_rsa ecr_token.txt ec2-user@$EC2_PUBLIC_IP:~/ecr_token.txt

# Configure and deploy to EC2
echo -e "Setting up EC2 instance and deploying application..."
ssh -o StrictHostKeyChecking=no -i ~/.ssh/id_rsa ec2-user@$EC2_PUBLIC_IP << EOF
  # Update system packages
  sudo yum update -y

  # Install Docker
  if ! command -v docker &> /dev/null; then
    echo "Installing Docker..."
    sudo dnf install docker -y  # Using dnf for Amazon Linux 2023
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo usermod -a -G docker ec2-user
  else
    echo "Docker already installed"
  fi

  # Install AWS CLI if not present
  if ! command -v aws &> /dev/null; then
    echo "Installing AWS CLI..."
    sudo dnf install awscli -y  # Using dnf for Amazon Linux 2023
  else
    echo "AWS CLI already installed"
  fi

  # Set up container deployment script
  cat > ~/deploy-container.sh << 'INNEREOF'
#!/bin/bash
set -e

# Variables from parent script
ECR_REPO="${ECR_REPO_URL}"
CONTAINER_NAME="${CONTAINER_NAME}"
CONVEX_URL="${CONVEX_URL}"

# Log in to ECR
cat ~/ecr_token.txt | sudo docker login --username AWS --password-stdin \$ECR_REPO

# Pull the latest image
echo "Pulling the latest Docker image..."
sudo docker pull \$ECR_REPO:latest

# Stop and remove existing container if it exists
echo "Stopping existing container if running..."
sudo docker stop \$CONTAINER_NAME 2>/dev/null || true
sudo docker rm \$CONTAINER_NAME 2>/dev/null || true

# Run the new container
echo "Starting new container..."
sudo docker run -d -p 80:3000 \\
  -e NODE_ENV=production \\
  -e NEXT_PUBLIC_CONVEX_URL="\$CONVEX_URL" \\
  --restart always \\
  --name \$CONTAINER_NAME \\
  \$ECR_REPO:latest

# Display running containers
echo "Container started. Current containers:"
sudo docker ps
INNEREOF

  # Make the script executable
  chmod +x ~/deploy-container.sh
  
  # Run the container deployment script
  echo "Running container deployment script..."
  ~/deploy-container.sh
  
  # Clean up the token file
  rm ~/ecr_token.txt
EOF

# Clean up local token file
rm ecr_token.txt

# Step 5: Verify deployment
echo -e "${GREEN}Step 5: Verifying deployment...${NC}"
echo -e "Waiting for application to be available..."

# Function to check if the site is up
check_site() {
  curl -s -o /dev/null -w "%{http_code}" http://$EC2_PUBLIC_IP
}

# Wait for the site to come up (timeout after 2 minutes)
start_time=$(date +%s)
timeout=120 # 2 minutes
until [ "$(check_site)" -eq 200 ] || [ $(($(date +%s) - start_time)) -gt $timeout ]; do
  echo -e "Waiting for application to become available... ($(($timeout - $(date +%s) + $start_time))s remaining)"
  sleep 5
done

if [ "$(check_site)" -eq 200 ]; then
  echo -e "${GREEN}Deployment successful!${NC}"
  echo -e "Application is now available at ${YELLOW}http://$EC2_PUBLIC_IP${NC}"
  echo -e "${YELLOW}Note: This IP address is temporary and will change if you destroy and redeploy the infrastructure.${NC}"
else
  echo -e "${YELLOW}Timeout reached, but application may still be starting up.${NC}"
  echo -e "Please check manually at ${YELLOW}http://$EC2_PUBLIC_IP${NC} in a few moments."
fi

echo -e "${GREEN}Deployment process completed!${NC}" 