resource "aws_iam_role" "ec2_role" {
  name = "${var.name}-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecr_read" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly" # or full ECR push/pull if needed
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.name}-instance-profile"
  role = aws_iam_role.ec2_role.name
}
