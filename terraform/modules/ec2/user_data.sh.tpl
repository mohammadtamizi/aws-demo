#!/bin/bash
set -e

# Define standard container name
CONTAINER_NAME="aws-demo-container"

# Update system packages
yum update -y

# Install Docker
amazon-linux-extras install docker -y
systemctl start docker
systemctl enable docker
usermod -a -G docker ec2-user

# Install AWS CLI
yum install -y aws-cli

# Configure Docker to use ECR
aws ecr get-login-password --region ${aws_region} | docker login --username AWS --password-stdin ${ecr_repository_url}

# Get the repository name from the URL
REPOSITORY_URL=${ecr_repository_url}
REPOSITORY_NAME=$(echo $REPOSITORY_URL | cut -d'/' -f2)
ACCOUNT_ID=$(echo $REPOSITORY_URL | cut -d'.' -f1 | cut -d'/' -f1)
REGION=${aws_region}

# Convex URL passed from Terraform variables
CONVEX_URL="${convex_url}"

# Pull the latest image
docker pull $REPOSITORY_URL:latest

# Run the container
docker run -d \
  --name $CONTAINER_NAME \
  -p 80:${app_port} \
  -e NEXT_PUBLIC_CONVEX_URL="$CONVEX_URL" \
  --restart always \
  $REPOSITORY_URL:latest

# Add a cron job to check for new images and update daily
echo "0 0 * * * /usr/bin/aws ecr get-login-password --region ${aws_region} | /usr/bin/docker login --username AWS --password-stdin ${ecr_repository_url} && /usr/bin/docker pull ${ecr_repository_url}:latest && /usr/bin/docker stop $CONTAINER_NAME && /usr/bin/docker rm $CONTAINER_NAME && /usr/bin/docker run -d --name $CONTAINER_NAME -p 80:${app_port} -e NEXT_PUBLIC_CONVEX_URL=\"$CONVEX_URL\" --restart always ${ecr_repository_url}:latest" | crontab -

# Create a simple health check script
cat > /home/ec2-user/health_check.sh << EOL
#!/bin/bash
if ! docker ps | grep -q $CONTAINER_NAME; then
  echo "Container not running, restarting..."
  docker start $CONTAINER_NAME || (docker rm $CONTAINER_NAME && docker run -d --name $CONTAINER_NAME -p 80:${app_port} -e NEXT_PUBLIC_CONVEX_URL="$CONVEX_URL" --restart always ${ecr_repository_url}:latest)
fi
EOL

chmod +x /home/ec2-user/health_check.sh

# Add a cron job to run the health check every 5 minutes
echo "*/5 * * * * /home/ec2-user/health_check.sh" | crontab -u ec2-user - 