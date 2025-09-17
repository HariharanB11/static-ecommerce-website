pipeline {
  agent any

  environment {
    AWS_REGION        = "us-east-1"
    AWS_ACCOUNT_ID    = "841162688608"
    ECR_REPO          = "static-ecommerce"
    IMAGE_TAG         = "${BUILD_NUMBER}"
    APP_EC2_PUBLIC_IP = "54.90.145.190"
  }

  stages {
    stage('Build Docker Image') {
      steps {
        script {
          sh """
            docker build -t ${ECR_REPO}:${IMAGE_TAG} site/
            docker tag ${ECR_REPO}:${IMAGE_TAG} ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}:${IMAGE_TAG}
          """
        }
      }
    }

    stage('Login & Push to ECR') {
      steps {
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-ecr-cred']]) {
          script {
            sh """
              aws ecr get-login-password --region ${AWS_REGION} \
                | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com

              docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}:${IMAGE_TAG}
            """
          }
        }
      }
    }

    stage('Deploy to app EC2') {
      steps {
        sshagent (credentials: ['app-ec2-ssh']) {
          sh """
            ssh -o StrictHostKeyChecking=no ec2-user@${APP_EC2_PUBLIC_IP} '
              aws ecr get-login-password --region ${AWS_REGION} \
                | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com &&

              docker pull ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}:${IMAGE_TAG} &&

              docker rm -f static-ecom || true &&

              docker run -d --restart unless-stopped --name static-ecom -p 80:80 \
                ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}:${IMAGE_TAG} &&

              docker image prune -f
            '
          """
        }
      }
    }
  }
}


