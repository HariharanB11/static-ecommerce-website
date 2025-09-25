output "app_instance_public_ip" {
  value = module.ec2_app.public_ip
}

output "app_ec2_public_ip" {
  value = aws_instance.app.public_ip
}

#output "jenkins_instance_public_ip" {
#  value = module.ec2_jenkins.public_ip
#}
output "ecr_repository_url" {
  value = module.ecr.repository_url
}

