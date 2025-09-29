```bash
#!/bin/bash
set -xe

# Detect OS and install updates + docker
if command -v yum >/dev/null 2>&1; then
  # Amazon Linux / RHEL
  yum update -y
  amazon-linux-extras install docker -y || yum install -y docker
  systemctl enable docker
  systemctl start docker
  usermod -aG docker ec2-user
elif command -v apt-get >/dev/null 2>&1; then
  # Ubuntu/Debian
  apt-get update -y
  apt-get install -y docker.io
  systemctl enable docker
  systemctl start docker
  usermod -aG docker ubuntu
fi

# Install docker-compose if enabled
if [ "${docker_compose}" = "true" ]; then
  curl -L "https://github.com/docker/compose/releases/download/2.20.2/docker-compose-$(uname -s)-$(uname -m)" \
    -o /usr/local/bin/docker-compose
  chmod +x /usr/local/bin/docker-compose
fi

# Install AWS CLI if missing
if ! command -v aws >/dev/null 2>&1; then
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  unzip awscliv2.zip
  ./aws/install
fi

# Login to ECR
aws ecr get-login-password --region ${region} \
  | docker login --username AWS --password-stdin ${aws_account_id}.dkr.ecr.${region}.amazonaws.com

# Pull and run app container
docker pull ${aws_account_id}.dkr.ecr.${region}.amazonaws.com/${ecr_repo}:${app_image_tag}
docker rm -f static-ecom || true
docker run -d --name static-ecom -p 80:80 \
  ${aws_account_id}.dkr.ecr.${region}.amazonaws.com/${ecr_repo}:${app_image_tag}
```
