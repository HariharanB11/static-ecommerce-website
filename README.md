# E-Commerce Website with Terraform + Jenkins CI/CD

This project provisions AWS infrastructure using **Terraform modules** and deploys a **Dockerized e-commerce website** via a **Jenkins CI/CD pipeline** triggered by GitHub webhooks.

## 🚀 Infrastructure
- VPC, Subnets, Internet Gateway, Route Table
- Security Groups
- EC2 (App instance) for running the Dockerized website
- EC2 (Jenkins instance) for CI/CD
- IAM Roles + Instance Profiles
- Amazon ECR repository for Docker images

## 📂 Project Structure

## 🛠️ CI/CD Flow
1. Developer pushes code to GitHub.
2. GitHub webhook triggers Jenkins pipeline.
3. Jenkins:
   - Builds Docker image of the static site.
   - Pushes image to Amazon ECR.
   - SSHs into App EC2 and deploys the new container.

## 🔧 Placeholders
- `<AWS_ACCOUNT_ID>` → Your AWS Account ID
- `<AWS_REGION>` → AWS region (e.g., us-east-1)
- `<KEY_PAIR_NAME>` → Your EC2 Key Pair
- `<APP_INSTANCE_PUBLIC_IP>` → Public IP of App EC2 (output from Terraform)
- `<JENKINS_CREDENTIAL_ID>` → Jenkins credential for AWS CLI
- `<ECR_REPO_NAME>` → ECR repository name

