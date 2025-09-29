output "app_instance_public_ip" {
  value = module.ec2_app.public_ip
}

output "app_instance_id" {
  value = module.ec2_app.instance_id
}

output "ecr_repository_url" {
  value = module.ecr.repository_url
}

