module "ecr" {
  source = "./modules/ecr"
 
  repository_name = "${var.project_name}-repo"
} 