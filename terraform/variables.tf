variable "aws_account_id" {
  description = "AWS Account ID"
  type        = string
}
variable "region" {
  default = "us-west-1"
}
variable "key_pair_name" {}
variable "ssh_public_key_path" {
  default = "~/.ssh/id_rsa.pub"
}
variable "vpc_cidr" {
  default = "10.0.0.0/16"
}
variable "public_subnet_cidr" {
  default = "10.0.1.0/24"
}
variable "app_instance_type" { default = "t3.micro" }
#variable "jenkins_instance_type" { default = "t3.small" }
variable "app_ami" { default = "" } # optional override
#variable "jenkins_ami" { default = "" } # optional override
variable "ecr_repo_name" { default = "static-ecommerce" }