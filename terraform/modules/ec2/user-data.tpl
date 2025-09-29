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
elif command -v apt-get >/dev/null 2>&1; then
    apt-get install -y docker.io
fi

# Start Docker service
sudo systemctl start docker
sudo systemctl enable docker

# Add default user to docker group
if command -v yum >/dev/null 2>&1; then
    sudo usermod -aG docker ec2-user || true
elif command -v apt-get >/dev/null 2>&1; then
    sudo usermod -aG docker ubuntu || true
fi

# Wait for Docker daemon to be ready
timeout=30
while ! docker info >/dev/null 2>&1 && [ $timeout -gt 0 ]; do
    echo "Waiting for Docker to start..."
    sleep 3
    timeout=$((timeout-3))
done

# Optional: Install Docker Compose
if [ "${docker_compose}" = "true" ]; then
    sudo curl -L "https://github.com/docker/compose/releases/download/2.20.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
fi

# -----------------------------
# AWS ECR login
# -----------------------------
aws ecr get-login-password --region ${region} \
  | sudo docker login --username AWS --password-stdin ${aws_account_id}.dkr.ecr.${region}.amazonaws.com

# -----------------------------
# Pull image and run container (Terraform-safe)
# -----------------------------
sudo docker pull ${aws_account_id}.dkr.ecr.${region}.amazonaws.com/${ecr_repo}$${:}${app_image_tag}
sudo docker rm -f static-ecom || true
sudo docker run -d --restart unless-stopped --name static-ecom -p 80$${80} ${aws_account_id}.dkr.ecr.${region}.amazonaws.com/${ecr_repo}$${:}${app_image_tag}






