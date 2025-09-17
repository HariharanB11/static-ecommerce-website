#!/bin/bash
# install updates, docker, docker-compose
yum update -y || apt-get update -y
# Install Docker (works for Amazon Linux/Ubuntu with checks) — keep simple for demo:
if command -v yum >/dev/null 2>&1; then
  amazon-linux-extras install docker -y || yum install -y docker
  service docker start
  usermod -a -G docker ec2-user || true
elif command -v apt-get >/dev/null 2>&1; then
  apt-get install -y docker.io
  systemctl start docker
  usermod -a -G docker ubuntu || true
fi

# Install docker-compose if requested
if [ "${docker_compose}" = "true" ]; then
  curl -L "https://github.com/docker/compose/releases/download/2.20.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  chmod +x /usr/local/bin/docker-compose
fi

# login to ECR and run container
aws ecr get-login-password --region ${region} | docker login --username AWS --password-stdin ${aws_account_id}.dkr.ecr.${region}.amazonaws.com || true

# Pull image and run (assumes tag passed)
docker pull ${aws_account_id}.dkr.ecr.${region}.amazonaws.com/${ecr_repo}:${app_image_tag} || true
docker rm -f static-ecom || true
docker run -d --name static-ecom -p 80:80 ${aws_account_id}.dkr.ecr.${region}.amazonaws.com/${ecr_repo}:${app_image_tag} || true
