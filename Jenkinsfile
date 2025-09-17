pipeline {
  agent any
  environment {
    AWS_REGION = 'us-east-1'         // update
    AWS_ACCOUNT_ID = '841162688608' 
    ECR_REPO = '841162688608.dkr.ecr.us-east-1.amazonaws.com/static-ecommerce'        // Update
    IMAGE_TAG = "${env.BUILD_ID}"
    APP_EC2_PUBLIC_IP = '54.90.145.190'               //update
  }
  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }
    stage('Build Docker image') {
      steps {
        sh "docker build -t ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}:${IMAGE_TAG} ./site"
      }
    }
    stage('Login to ECR') {
      steps {
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-ecr-cred']]) {
          sh """
            aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
          """
        }
      }
    }
    stage('Push to ECR') {
      steps {
        sh "docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}:${IMAGE_TAG}"
      }
    }
    stage('Deploy to app EC2') {
      steps {
        // Option A — SSH & docker pull & restart
        sshagent (credentials: ['app-ec2-ssh']) {
          sh """
            ssh -o StrictHostKeyChecking=no ec2-user@${APP_EC2_PUBLIC_IP} '      
              docker pull ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}:${IMAGE_TAG} &&
              docker rm -f static-ecom || true &&
              docker run -d --name static-ecom -p 80:80 ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}:${IMAGE_TAG}
            '
          """
        }
      }
    }
  }
}
