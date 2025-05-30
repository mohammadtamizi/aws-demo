# AWS Deployment Demo with Terraform

This project demonstrates how to deploy a containerized Next.js application to AWS using Terraform, staying within the AWS Free Tier.

## Architecture

The demo uses the following AWS services, all within the Free Tier:

* **Amazon ECR**: To host the Docker image
* **Amazon EC2 (t2.micro)**: To run the application container using a specific Amazon Linux 2023 AMI (ami-0953476d60561c955)
* **Temporary Public IP**: Automatically assigned to the EC2 instance (no Elastic IP costs)

## Project Components

* **Frontend**: Next.js application with Tailwind CSS for styling
* **Backend**: Convex for serverless backend functionality
* **Container**: Docker for application packaging and deployment
* **Infrastructure**: Terraform for AWS resource provisioning

## Public IP Address Considerations

This project uses temporary public IP addresses rather than Elastic IPs to avoid AWS charges:

- **Temporary Public IPs**: Automatically assigned when the instance launches, released when terminated
- **Cost Benefits**: No charges for temporary IPs (Elastic IPs incur charges when not attached to running instances)
- **Important Note**: The IP address will change each time you redeploy. The deploy script will display the current IP address

## Prerequisites

* AWS CLI configured with appropriate access credentials
* Terraform (>= 1.0.0)
* Docker
* jq
* An SSH key pair (default: ~/.ssh/id_rsa.pub)

## SSH Key Setup

The deployment requires an SSH key for secure access to the EC2 instance:

1. If you don't have an SSH key, create one:
   ```bash
   ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa
   ```

2. Make sure your public key is located at `~/.ssh/id_rsa.pub`

3. The default path can be changed in `terraform/variables.tf` if needed

## Deployment

To deploy the application to AWS:

1. **Configure AWS CLI**:
   ```bash
   aws configure
   ```

2. **Set Environment Variables**:
   ```bash
   # Set your Convex backend URL
   export NEXT_PUBLIC_CONVEX_URL="your-convex-url-here"
   ```

3. **Run the Deployment Script**:
   ```bash
   ./deploy.sh
   ```

The script will:
- Create the necessary AWS infrastructure (ECR, EC2, networking)
- Build and push a Docker image to ECR
- Deploy the application to the EC2 instance

## EC2 Instance Configuration

The EC2 instance is configured with:

* **Amazon Linux 2023 AMI**: Fixed AMI ID (ami-0953476d60561c955)
  * This specific AMI is used because it's eligible for AWS Free Tier in the us-east-1 region
  * If deploying to a different region, you'll need to update this AMI ID in `terraform/modules/ec2/main.tf`
* **Package Management**: Uses `dnf` for package installation
* **Automatic Updates**: Daily container updates via cron job
* **Health Monitoring**: Container health check every 5 minutes

## Container Environment

The Docker container runs with:

* **Environment Variables**:
  * `NODE_ENV=production`
  * `NEXT_PUBLIC_CONVEX_URL` for backend connectivity
* **Port Mapping**: Maps container port 3000 to host port 80
* **Restart Policy**: Set to "always" for automatic recovery

## Staying Within Free Tier Limits

This deployment is designed to stay within AWS Free Tier limits:

* **EC2**: Uses t2.micro instance (750 hours/month free)
* **ECR**: Limited image storage (<500MB/month free)
* **Temporary Public IP**: Free when attached to a running EC2 instance

## Cost Monitoring

To avoid unexpected AWS charges, it's recommended to:

1. **Set up AWS Budgets**: Create a budget with alerts when costs exceed a threshold
   ```bash
   aws budgets create-budget --account-id $(aws sts get-caller-identity --query 'Account' --output text) \
     --budget file://budget.json --notifications-with-subscribers file://notifications.json
   ```

2. **Enable AWS Cost Explorer**: Monitor costs through the AWS Console

3. **Set up AWS CloudWatch Alarms**: Create alarms for unusual activity
   
4. **Always Clean Up Resources**: Run the cleanup script when you're done with the demo

5. **Check AWS Billing Dashboard**: Regularly monitor your AWS billing dashboard

⚠️ **Important Note**: Always run the cleanup script when you're done to ensure all resources are properly terminated and to avoid any unexpected charges.

## Terraform State Management

This project is configured to use Terraform's local backend, which means the state file is stored locally in the `terraform` directory. This approach simplifies the setup for demonstration purposes.

For a production environment, you would typically want to use a remote backend (like S3) for better collaboration and security.

## Cleanup

To avoid any unexpected costs, always clean up resources when you're done:

```bash
./cleanup.sh
```

The cleanup script:
1. Removes all Docker images from ECR
2. Safely stops the EC2 instance
3. Destroys all AWS resources created by Terraform
4. Verifies successful resource cleanup

## Troubleshooting

### EC2 Instance Not Accessible
- Check the security group rules
- Verify that the EC2 instance is running
- Confirm the Docker container is running with `docker ps`
- Allow more time for instance initialization (the script waits 30 seconds)

### ECR Authentication Issues
- Ensure AWS CLI is properly configured
- Try re-authenticating with: `aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <ECR_REPO_URL>`

### Resource Destruction Errors
- Resources must be destroyed in the correct order due to dependencies
- The cleanup script handles this automatically
- For manual cleanup, destroy resources in this order: EC2 → ECR 

## Environment Variables

The application uses the following environment variables:

| Variable | Description | Required | Default |
|----------|-------------|----------|---------|
| `NEXT_PUBLIC_CONVEX_URL` | The URL for your Convex backend | Yes | None |

You can set these variables in several ways:

1. **For local development**: Create a `.env.local` file in the aws-demo directory:
   ```
   NEXT_PUBLIC_CONVEX_URL=your-convex-url-here
   ```

2. **For deployment**: Set the environment variable before running the deploy script:
   ```bash
   export NEXT_PUBLIC_CONVEX_URL="your-convex-url-here"
   ./deploy.sh
   ```

3. **For production**: The deploy script will pass the environment variable to the Docker container and EC2 instance.

## Convex Backend

This project uses [Convex](https://www.convex.dev/) as the backend service, which provides:

1. **Real-time data synchronization** for tracking visitor statistics
2. **Serverless backend** with automatic scaling
3. **Integration with authentication** (via Clerk)
4. **Database management** without the need to set up a separate database

To set up your own Convex backend:

1. Sign up at [Convex](https://www.convex.dev/)
2. Create a new project
3. Use the Convex URL provided by Convex as your `NEXT_PUBLIC_CONVEX_URL` environment variable 