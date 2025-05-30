module "ec2" {
  source = "./modules/ec2"

  project_name       = var.project_name
  aws_region         = var.aws_region
  instance_type      = var.instance_type
  app_port           = var.app_port
  ssh_cidr_block     = var.ssh_cidr_block
  public_key_path    = var.public_key_path
  ecr_repository_url = module.ecr.repository_url
  convex_url         = var.convex_url

  # This dependency ensures the ECR repository is created before the EC2 instance
  depends_on = [
    module.ecr
  ]
} 