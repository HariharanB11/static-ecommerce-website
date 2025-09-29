pipeline {
    agent any

    parameters {
        choice(
            name: 'ACTION',
            choices: ['create', 'destroy'],
            description: 'Choose whether to create infra and deploy app OR destroy infra'
        )
        string(
            name: 'AWS_ACCOUNT_ID',
            defaultValue: '411571901235',
            description: 'AWS Account ID'
        )
        string(
            name: 'KEY_PAIR_NAME',
            defaultValue: 'demo-key',
            description: 'EC2 Key Pair Name'
        )
    }

    environment {
        AWS_REGION = "us-east-1"
        ECR_REPO = "static-ecommerce"
        IMAGE_TAG = "${BUILD_NUMBER}"
        ECR_REPO_URL = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}"
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
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-creds']]) {
                        sh "terraform init"
                    }
                }
            }
        }

        stage('Terraform Apply') {
            when { expression { params.ACTION == 'create' } }
            steps {
                dir('terraform') {
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-creds']]) {
                        sh """
                            terraform plan -out=tfplan \
                                -var="aws_account_id=${params.AWS_ACCOUNT_ID}" \
                                -var="key_pair_name=${params.KEY_PAIR_NAME}"
                            terraform apply -auto-approve tfplan
                        """
                    }
                }
            }
        }

        stage('Terraform Destroy') {
            when { expression { params.ACTION == 'destroy' } }
            steps {
                dir('terraform') {
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-creds']]) {
                        sh """
                            terraform destroy -auto-approve \
                                -var="aws_account_id=${params.AWS_ACCOUNT_ID}" \
                                -var="key_pair_name=${params.KEY_PAIR_NAME}"
                        """
                    }
                }
            }
        }

        stage('Get Terraform Outputs') {
            when { expression { params.ACTION == 'create' } }
            steps {
                dir('terraform') {
                    script {
                        env.APP_EC2_PUBLIC_IP = sh(script: "terraform output -raw app_instance_public_ip", returnStdout: true).trim()
                        echo "EC2 Public IP: ${env.APP_EC2_PUBLIC_IP}"
                    }
                }
            }
        }

        stage('Validate Dockerfile') {
            when { expression { params.ACTION == 'create' } }
            steps {
                sh "hadolint site/Dockerfile || true"
            }
        }

        stage('Build Docker Image') {
            when { expression { params.ACTION == 'create' } }
            steps {
                sh "docker build --no-cache -t ${ECR_REPO}:${IMAGE_TAG} site/"
            }
        }

        stage('Tag Docker Image') {
            when { expression { params.ACTION == 'create' } }
            steps {
                sh "docker tag ${ECR_REPO}:${IMAGE_TAG} ${ECR_REPO_URL}:${IMAGE_TAG}"
            }
        }

        stage('Login to AWS ECR') {
            when { expression { params.ACTION == 'create' } }
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-creds']]) {
                    sh """
                        aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REPO_URL.split('/')[0]}
                    """
                }
            }
        }

        stage('Push Docker Image to ECR') {
            when { expression { params.ACTION == 'create' } }
            steps {
                sh "docker push ${ECR_REPO_URL}:${IMAGE_TAG}"
            }
        }

        stage('Wait for EC2 to be Ready') {
            when { expression { params.ACTION == 'create' } }
            steps {
                sleep(time: 60, unit: 'SECONDS')
            }
        }

        stage('Deploy to EC2 Instance') {
            when { expression { params.ACTION == 'create' } }
            steps {
                sshagent(['app-ec2-ssh']) {
                    sh """
                        ssh -o StrictHostKeyChecking=no ec2-user@${APP_EC2_PUBLIC_IP} '
                            aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REPO_URL.split('/')[0]} &&
                            docker pull ${ECR_REPO_URL}:${IMAGE_TAG} &&
                            docker rm -f static-ecom || true &&
                            docker run -d --restart unless-stopped --name static-ecom -p 80:80 ${ECR_REPO_URL}:${IMAGE_TAG} &&
                            docker image prune -f
                        '
                    """
                }
            }
        }

        stage('Verify Deployment') {
            when { expression { params.ACTION == 'create' } }
            steps {
                sshagent(['app-ec2-ssh']) {
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
                    echo "✅ Deployment successful! Application is live on http://${env.APP_EC2_PUBLIC_IP}"
                } else {
                    echo "✅ Terraform destroy completed. Infrastructure removed."
                }
            }
        }
        failure {
            echo "❌ Pipeline failed. Please check Jenkins logs."
        }
    }

} // end of pipeline

