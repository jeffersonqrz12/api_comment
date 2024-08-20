provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source = "./modules/vpc"
}

module "ecr" {
  source          = "./modules/ecr"
}

module "ecs" {
  source              = "./modules/ecs"
  ecr_repository_url  = module.ecr.repository_url
  vpc_id              = module.vpc.vpc_id
  subnet_id           = module.vpc.public_subnet_id
  cluster_name        = "my-ecs-cluster"
}
