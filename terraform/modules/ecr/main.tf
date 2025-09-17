resource "aws_ecr_repository" "this" {
  name                 = var.name
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
  tags = { Name = var.name }
}
output "repository_url" { value = aws_ecr_repository.this.repository_url }
