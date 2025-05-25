provider "aws" {
  region = var.region
  profile = var.aws_profile
}

module "vpc" {
  source     = "./modules/vpc"
  cidr_block = var.cidr_block
}

module "security_group" {
  source = "./modules/security_group"
  vpc_id = module.vpc.vpc_id
}

module "ecs" {
  source            = "./modules/ecs"
  log_group_name    = "nims_tofu_cloud_logs"
  region            = var.region
  secret            = var.secret
  subnet_ids        = module.vpc.subnet_ids
  security_group_id = module.security_group.security_group_id
  vpc_id = module.vpc.vpc_id
}

