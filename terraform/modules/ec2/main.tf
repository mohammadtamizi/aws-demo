# Get the latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Create a VPC for our EC2 instance
resource "aws_vpc" "app_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

# Create a public subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.app_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "${var.aws_region}a"

  tags = {
    Name = "${var.project_name}-public-subnet"
  }
}

# Create an internet gateway
resource "aws_internet_gateway" "app_igw" {
  vpc_id = aws_vpc.app_vpc.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

# Create a route table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.app_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.app_igw.id
  }

  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

# Associate route table with subnet
resource "aws_route_table_association" "public_rta" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# Create security group for EC2 instance
resource "aws_security_group" "app_sg" {
  name        = "${var.project_name}-sg"
  description = "Security group for the app EC2 instance"
  vpc_id      = aws_vpc.app_vpc.id

  # Allow HTTP traffic
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP"
  }

  # Allow traffic on the app port
  ingress {
    from_port   = var.app_port
    to_port     = var.app_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Application port"
  }

  # Allow SSH (restrict to your IP in production)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_cidr_block]
    description = "SSH"
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  # Ensure the security group is deleted when the VPC is destroyed
  lifecycle {
    create_before_destroy = true
  }
}

# Create an EC2 key pair for SSH access
resource "aws_key_pair" "app_key_pair" {
  key_name   = "${var.project_name}-key"
  public_key = file(var.public_key_path)
}

# Create the EC2 instance
resource "aws_instance" "app_instance" {
  ami                    = "ami-0953476d60561c955"
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.app_sg.id]
  key_name               = aws_key_pair.app_key_pair.key_name
  associate_public_ip_address = true  # Ensure instance gets a temporary public IP

  root_block_device {
    volume_size           = 8
    volume_type           = "gp3"
    delete_on_termination = true
  }

  # User data script to install Docker and run the container
  user_data = templatefile("${path.module}/user_data.sh.tpl", {
    ecr_repository_url = var.ecr_repository_url
    aws_region         = var.aws_region
    app_port           = var.app_port
    convex_url         = var.convex_url
  })

  tags = {
    Name = "${var.project_name}-instance"
  }

  # To ensure proper order of resource creation and destruction
  depends_on = [
    aws_internet_gateway.app_igw
  ]
}

# We're no longer using Elastic IP resources to avoid costs
# The following resources have been removed:
# - aws_eip
# - aws_eip_association 