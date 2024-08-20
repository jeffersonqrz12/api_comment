provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source = "./modules/vpc/main.tf"
}

module "ecr" {
  source          = "./modules/ecr/main.tf"
  repository_name = "my-app-repo"
}

module "ecs" {
  source              = "./modules/ecs/main.tf"
  ecr_repository_url  = module.ecr.repository_url
  vpc_id              = module.vpc.vpc_id
  subnet_id           = module.vpc.public_subnet_id
  cluster_name        = "my-ecs-cluster"
}
