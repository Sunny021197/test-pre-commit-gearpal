# ECR repository for eai-tmnagpt-process-service
resource "aws_ecr_repository" "eai_gearpal_repo" {
  name                 = "${var.app_name}-${var.environment}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
  tags = merge({ Name = var.app_name}, var.tags)
}

# Data source to get the most recent image from ECR
data "aws_ecr_image" "latest_image" {
  repository_name = aws_ecr_repository.eai_gearpal_repo.name
  most_recent     = true
}

resource "aws_ecr_lifecycle_policy" "deletepolicy" {
  repository = aws_ecr_repository.eai_gearpal_repo.name

  policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Keep last 10 images",
            "selection": {
                "tagStatus": "any",
                "countType": "imageCountMoreThan",
                "countNumber": 10
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}
