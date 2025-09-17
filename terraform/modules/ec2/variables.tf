variable "name" {}
variable "ami_id" {}
variable "instance_type" {}
variable "subnet_id" {}
variable "vpc_id" {}
variable "key_name" {}
variable "ssh_allowed_cidrs" { default = ["0.0.0.0/0"] }
variable "app_allowed_cidrs" { default = ["0.0.0.0/0"] }
variable "app_port" { default = 80 }
variable "instance_profile_name" { default = "" }
variable "ecr_repo" { default = "" }
variable "region" { default = "us-east-1" }
variable "use_docker_compose" { default = true }
variable "app_image_tag" { default = "latest" }
