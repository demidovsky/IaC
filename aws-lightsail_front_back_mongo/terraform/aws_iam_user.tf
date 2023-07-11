resource "aws_iam_user" "ecr_user" {
  name = "ecr-user"
}

resource "aws_iam_access_key" "ecr_user_access_key" {
  user    = aws_iam_user.ecr_user.name
}

resource "aws_iam_user_policy_attachment" "ecr_user_policy_attachment" {
  user       = aws_iam_user.ecr_user.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

output "access_key" {
  sensitive = true
  value     = aws_iam_access_key.ecr_user_access_key.id
}

output "secret_key" {
  sensitive = true
  value     = aws_iam_access_key.ecr_user_access_key.secret
}