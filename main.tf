provider "aws" {
  region = var.region
}

module "vpc" {
  source              = "./modules/vpc"
  name                = var.project_name
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
  az                  = var.availability_zone
}

module "security_group" {
  source = "./modules/security-group"
  name   = var.project_name
  vpc_id = module.vpc.vpc_id
}

module "ec2" {
  source        = "./modules/ec2"
  name          = var.project_name
  ami           = var.ami
  instance_type = var.instance_type
  subnet_id     = module.vpc.public_subnet_id
  key_name      = var.key_name
  sg_id         = module.security_group.sg_id
  user_data     = "user_data.sh"
}

output "ec2_public_ip" {
  value = module.ec2.instance_public_ip
}
