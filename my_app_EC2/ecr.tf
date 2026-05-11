resource "aws_ecr_repository" "my_app" {
  name = "my_app"

  image_scanning_configuration {
    scan_on_push = true
  }
}

output "ecr_repository_url" {
  value = aws_ecr_repository.my_app.repository_url
}