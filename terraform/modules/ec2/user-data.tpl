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
curl "[https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip](https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip)" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install
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

systemctl start docker
systemctl enable docker

# Add default user to docker group

if id "ec2-user" &>/dev/null; then
usermod -aG docker ec2-user || true
elif id "ubuntu" &>/dev/null; then
usermod -aG docker ubuntu || true
fi

# Wait for Docker daemon to be ready

timeout=60
while ! docker info >/dev/null 2>&1 && [ $timeout -gt 0 ]; do
echo "Waiting for Docker to start..."
sleep 3
timeout=$((timeout-3))
done

# Optional: Install Docker Compose

if [ "${docker_compose}" = "true" ]; then
curl -L "[https://github.com/docker/compose/releases/download/2.20.2/docker-compose-$(uname](https://github.com/docker/compose/releases/download/2.20.2/docker-compose-$%28uname) -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
fi

# -----------------------------

# AWS ECR login

# -----------------------------

echo "Logging in to Amazon ECR..."
aws ecr get-login-password --region ${region} 
| docker login --username AWS --password-stdin ${aws_account_id}.dkr.ecr.${region}.amazonaws.com

# -----------------------------

# Pull image and run container

# -----------------------------

echo "Pulling Docker image: ${aws_account_id}.dkr.ecr.${region}.amazonaws.com/${ecr_repo}:${app_image_tag}"
docker pull ${aws_account_id}.dkr.ecr.${region}.amazonaws.com/${ecr_repo}:${app_image_tag}

docker rm -f static-ecom || true
docker run -d --restart unless-stopped --name static-ecom -p 80:80 
${aws_account_id}.dkr.ecr.${region}.amazonaws.com/${ecr_repo}:${app_image_tag}

# -----------------------------

# Health check

# -----------------------------

echo "Waiting for container to initialize..."
sleep 15

max_attempts=12
attempt=1
until curl -s -o /dev/null -w "%%{http_code}" [http://localhost:80](http://localhost:80) | grep -q "200"; do
if [ $attempt -ge $max_attempts ]; then
echo "❌ Container failed to start after $max_attempts attempts!"
exit 1
fi
echo "Container not ready yet... (Attempt $attempt/$max_attempts)"
sleep 5
attempt=$((attempt+1))
done

echo "✅ Container is up and running!"









