resource "aws_security_group" "this" {
  name        = "${var.name}-sg"
  description = "SG for ${var.name}"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ssh_allowed_cidrs
  }

  ingress {
    from_port   = var.app_port
    to_port     = var.app_port
    protocol    = "tcp"
    cidr_blocks = var.app_allowed_cidrs
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "this" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  key_name      = var.key_name
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.this.id]

  iam_instance_profile = var.instance_profile_name != "" ? var.instance_profile_name : null

  user_data = templatefile("${path.module}/user-data.tpl", {
    ecr_repo       = var.ecr_repo
    region         = var.region
    docker_compose = var.use_docker_compose
    app_image_tag  = var.app_image_tag
  })

  tags = {
    Name = var.name
  }
}

output "public_ip" { value = aws_instance.this.public_ip }
output "instance_id" { value = aws_instance.this.id }
