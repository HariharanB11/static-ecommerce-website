#!/bin/bash
set -e

# -----------------------------
# Update packages
# -----------------------------
if command -v yum >/dev/null 2>&1; then
    yum update -y
    yum install -y unzip curl
elif command -v apt-get >/dev/null 2>&1; then
    apt-get update -y
    apt-get install -y unzip curl
fi

# -----------------------------
# Install AWS CLI v2
# -----------------------------
if ! command -v aws >/dev/null 2>&1; then
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
    rm -rf awscliv2.zip aws
fi

# -----------------------------
# Install Docker
# -----------------------------
if command -v yum >/dev/null 2>&1; then
    amazon-linux-extras install docker -y || yum install -y docker
    systemctl start docker
    systemctl enable docker
    usermod -a -G docker ec2-user || true
elif command -v apt-get >/dev/null 2>&1; then
    apt-get install -y docker.io
    systemctl start docker
    systemctl enable docker
    usermod -a -G docker ubuntu || true
fi

# -----------------------------
# Install Docker Compose (optional)
# -----------------------------
if [ "${docker_compose}" = "true" ]; then
    curl -L "https://github.com/docker/compose/releases/download/2.20.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
fi

# -----------------------------
# AWS ECR login
# -----------------------------
aws ecr get-login-password --region ${region} \
  | docker login --username AWS --password-stdin ${aws_account_id}.dkr.ecr.${region}.amazonaws.com || true

# -----------------------------
# Pull image and run container
# -----------------------------
docker pull ${aws_account_id}.dkr.ecr.${region}.amazonaws.com/${ecr_repo}:${app_image_tag} || true
docker rm -f static-ecom || true
docker run -d --restart unless-stopped --name static-ecom -p 80:80 ${aws_account_id}.dkr.ecr.${region}.amazonaws.com/${ecr_repo}:${app_image_tag} || true


