pipeline {
  agent any

  parameters {
    choice(
      name: 'ACTION',
      choices: ['create', 'destroy'],
      description: 'Choose whether to create infra and deploy app OR destroy infra' 
    )
  }

  environment {
    AWS_REGION     = "us-east-1"
    AWS_ACCOUNT_ID = "411571901235"
    ECR_REPO       = "static-ecommerce"
    IMAGE_TAG      = "${BUILD_NUMBER}"
  }

  stages {
    stage('Checkout Source Code') {
      steps {
        echo "Checking out code from GitHub..."
        checkout scm
      }
    }

    stage('Terraform Init') {
      steps {
        dir('terraform') {
          sh "terraform init"
        }
      }
    }

    stage('Terraform Apply') {
      when { expression { params.ACTION == 'create' } }
      steps {
        dir('terraform') {
          sh "terraform plan -out=tfplan"
          sh "terraform apply -auto-approve tfplan"
        }
      }
    }

    stage('Terraform Destroy') {
      when { expression { params.ACTION == 'destroy' } }
      steps {
        dir('terraform') {
          sh "terraform destroy -auto-approve"
        }
      }
    }

    stage('Get Terraform Outputs') {
      when { expression { params.ACTION == 'create' } }
      steps {
        dir('terraform') {
          script {
            APP_EC2_PUBLIC_IP = sh(script: "terraform output -raw app_ec2_public_ip", returnStdout: true).trim()
            echo "EC2 Public IP: ${APP_EC2_PUBLIC_IP}"
            env.APP_EC2_PUBLIC_IP = APP_EC2_PUBLIC_IP
          }
        }
      }
    }

    stage('Validate Dockerfile') {
      when { expression { params.ACTION == 'create' } }
      steps {
        echo "Validating Dockerfile syntax..."
        sh "hadolint site/Dockerfile || true"
      }
    }

    stage('Build Docker Image') {
      when { expression { params.ACTION == 'create' } }
      steps {
        echo "Building Docker image..."
        sh "docker build -t ${ECR_REPO}:${IMAGE_TAG} site/"
      }
    }

    stage('Tag Docker Image') {
      when { expression { params.ACTION == 'create' } }
      steps {
        echo "Tagging Docker image for ECR..."
        sh "docker tag ${ECR_REPO}:${IMAGE_TAG} ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}:${IMAGE_TAG}"
      }
    }

    stage('Login to AWS ECR') {
      when { expression { params.ACTION == 'create' } }
      steps {
        echo "Logging in to AWS ECR..."
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-ecr-cred']]) {
          sh "aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
        }
      }
    }

    stage('Push Docker Image to ECR') {
      when { expression { params.ACTION == 'create' } }
      steps {
        echo "Pushing Docker image to AWS ECR..."
        sh "docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}:${IMAGE_TAG}"
      }
    }

    stage('Deploy to EC2 Instance') {
      when { expression { params.ACTION == 'create' } }
      steps {
        echo "Deploying application on EC2..."
        sshagent (credentials: ['app-ec2-ssh']) {
          sh """
            ssh -o StrictHostKeyChecking=no ec2-user@${APP_EC2_PUBLIC_IP} '
              aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com &&
              docker pull ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}:${IMAGE_TAG} &&
              docker rm -f static-ecom || true &&
              docker run -d --restart unless-stopped --name static-ecom -p 80:80 ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}:${IMAGE_TAG} &&
              docker image prune -f
            '
          """
        }
      }
    }

    stage('Verify Deployment') {
      when { expression { params.ACTION == 'create' } }
      steps {
        echo "Verifying if application is running..."
        sshagent (credentials: ['app-ec2-ssh']) {
          sh """
            ssh -o StrictHostKeyChecking=no ec2-user@${APP_EC2_PUBLIC_IP} '
              docker ps | grep static-ecom
            '
          """
        }
      }
    }
  }

  post {
    success {
      script {
        if (params.ACTION == 'create') {
          echo "✅ Deployment successful! Application is live on http://${APP_EC2_PUBLIC_IP}"
        } else {
          echo "✅ Terraform destroy completed. Infrastructure removed."
        }
      }
    }
    failure {
      echo "❌ Pipeline failed. Please check Jenkins logs."
    }
  }
}
