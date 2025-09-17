# Jenkins Setup Commands

## 1. Install Jenkins on EC2 (Amazon Linux 2)
```bash
sudo yum update -y
sudo amazon-linux-extras install java-openjdk11 -y
wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
yum install jenkins -y
systemctl enable jenkins
systemctl start jenkins
