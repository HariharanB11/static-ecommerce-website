pipeline {
agent any

environment {
AWS_REGION     = "us-east-1"            // AWS region 
AWS_ACCOUNT_ID = "411571901235"         // AWS Account ID
ECR_REPO       = "static-ecommerce"     // ECR repo name
IMAGE_TAG      = "${BUILD_NUMBER}"     
}

stages {
stage('Checkout Source Code') {
steps {
echo "📥 Checking out code from GitHub..."
checkout scm
}
}

```
stage('Terraform Init & Apply') {
  steps {
    echo "⚙️ Running Terraform to provision infra..."
    dir('terraform') {
      sh "terraform init -input=false"
      sh "terraform apply -auto-approve -input=false"
    }
  }
}

stage('Get App EC2 Public IP') {
  steps {
    script {
      echo "🌐 Fetching App EC2 public IP from Terraform output..."
      env.APP_EC2_PUBLIC_IP = sh(
        script: "cd terraform && terraform output -raw app_ec2_ip",
        returnStdout: true
      ).trim()
      echo "✅ App EC2 Public IP: ${APP_EC2_PUBLIC_IP}"
    }
  }
}

stage('Validate Dockerfile') {
  steps {
    echo "🔍 Validating Dockerfile syntax (hadolint optional)..."
    sh "hadolint site/Dockerfile || true"
  }
}

stage('Build Docker Image') {
  steps {
    echo "🐳 Building Docker image (no cache to pick new site changes)..."
    sh "docker build --no-cache -t ${ECR_REPO}:${IMAGE_TAG} site/"
  }
}

stage('Tag Docker Image') {
  steps {
    echo "🏷️ Tagging Docker image for ECR..."
    sh "docker tag ${ECR_REPO}:${IMAGE_TAG} ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}:${IMAGE_TAG}"
  }
}

stage('Login to AWS ECR') {
  steps {
    echo "🔑 Logging in to AWS ECR..."
    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-ecr-cred']]) {
      sh "aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
    }
  }
}

stage('Push Docker Image to ECR') {
  steps {
    echo "🚀 Pushing Docker image to AWS ECR..."
    sh "docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}:${IMAGE_TAG}"
  }
}

stage('Deploy to EC2 Instance') {
  steps {
    echo "📦 Deploying application on EC2..."
    sshagent (credentials: ['app-ec2-ssh']) {
      sh """
        ssh -o StrictHostKeyChecking=no ec2-user@${APP_EC2_PUBLIC_IP} '
          echo "🔑 Logging in to AWS ECR on EC2..."
          aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com &&

          echo "📥 Pulling latest Docker image..."
          docker pull ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}:${IMAGE_TAG} &&

          echo "🛑 Stopping old container (if exists)..."
          docker rm -f static-ecom || true &&

          echo "▶️ Starting new container..."
          docker run -d --restart unless-stopped --name static-ecom -p 80:80 ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}:${IMAGE_TAG} &&

          echo "🧹 Cleaning up unused images..."
          docker image prune -f &&
          docker rmi \$(docker images -f "dangling=true" -q) || true
        '
      """
    }
  }
}

stage('Verify Deployment') {
  steps {
    echo "🔎 Verifying if application is running..."
    sshagent (credentials: ['app-ec2-ssh']) {
      sh """
        ssh -o StrictHostKeyChecking=no ec2-user@${APP_EC2_PUBLIC_IP} '
          docker ps | grep static-ecom
        '
      """
    }
  }
}
```

}

post {
success {
echo "✅ Deployment successful! Application is live on http://${APP_EC2_PUBLIC_IP}"
}
failure {
echo "❌ Deployment failed. Please check Jenkins logs."
}
}
}
