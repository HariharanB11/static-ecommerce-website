variable "vpc_cidr" {
  type = string
}

variable "public_subnet_cidr" {
  type = string
}

variable "prefix" {
  type    = string
  default = "static-ecom"
}
