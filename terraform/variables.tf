variable "aws_account_id" {
  description = "AWS Account ID"
  type        = string
}

variable "region" {
  description = "AWS Region to deploy resources in"
  type        = string
  default     = "us-west-1"
}

variable "key_pair_name" {
  description = "EC2 Key Pair Name (must exist in your AWS account)"
  type        = string
  default     = "demo-key"   # <-- your actual existing key pair
}

variable "ssh_public_key_path" {
  description = "Path to your local SSH public key"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "app_instance_type" {
  description = "EC2 instance type for the application server"
  type        = string
  default     = "t3.micro"
}

#variable "jenkins_instance_type" {
#  description = "EC2 instance type for Jenkins server"
#  type        = string
#  default     = "t3.small"
#}

variable "app_ami" {
  description = "Optional override for AMI ID to use for the app server"
  type        = string
  default     = "" 
}

#variable "jenkins_ami" {
#  description = "Optional override for AMI ID to use for Jenkins server"
#  type        = string
#  default     = ""
#}

variable "ecr_repo_name" {
  description = "Name of the ECR repository"
  type        = string
  default     = "static-ecommerce"
}
