output "app_instance_public_ip" {
  value = module.ec2_app.aws_instance.this.public_ip
}

output "app_instance_id" {
  value = module.ec2_app.aws_instance.this.id
}

