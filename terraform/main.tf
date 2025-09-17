module "vpc" {
  source = "./modules/vpc"
  vpc_cidr = var.vpc_cidr
  public_subnet_cidr = var.public_subnet_cidr
  prefix = "static-ecom"
}

module "iam" {
  source = "./modules/iam"
  name = "static-ecom"
}

module "ecr" {
  source = "./modules/ecr"
  name = var.ecr_repo_name
}

module "ec2_app" {
  source = "./modules/ec2"
  name = "app"
  ami_id = var.app_ami != "" ? var.app_ami : data.aws_ami.amazon_linux.id
  instance_type = var.app_instance_type
  subnet_id = module.vpc.public_subnet_id
  vpc_id = module.vpc.vpc_id
  key_name = var.key_pair_name
  ssh_allowed_cidrs = ["0.0.0.0/0"]  # lock down to your IP
  app_allowed_cidrs = ["0.0.0.0/0"]
  instance_profile_name = module.iam.instance_profile_name
  ecr_repo = var.ecr_repo_name
  region = var.region
  use_docker_compose = true
  app_image_tag = "latest"
}

module "ec2_jenkins" {
  source = "./modules/ec2"
  name = "jenkins"
  ami_id = var.jenkins_ami != "" ? var.jenkins_ami : data.aws_ami.amazon_linux.id
  instance_type = var.jenkins_instance_type
  subnet_id = module.vpc.public_subnet_id
  vpc_id = module.vpc.vpc_id
  key_name = var.key_pair_name
  ssh_allowed_cidrs = ["0.0.0.0/0"] # lock down to your IP
  app_allowed_cidrs = ["0.0.0.0/0"]
  instance_profile_name = module.iam.instance_profile_name
  ecr_repo = var.ecr_repo_name
  region = var.region
  use_docker_compose = false
  app_image_tag = ""
}

data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}
