# ============================================================================
# ECR MODULE  — creates one repository per name passed in.
# For zidd2: zidd-auth-service, zidd-chat-service, zid-frontend
# ============================================================================

resource "aws_ecr_repository" "this" {
  for_each             = toset(var.repository_names)
  name                 = each.value
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true # basic vulnerability scan on every push
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = { Name = each.value }
}

# Keep only the last N images per repo to control storage cost.
resource "aws_ecr_lifecycle_policy" "this" {
  for_each   = aws_ecr_repository.this
  repository = each.value.name
  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Expire untagged images after 7 days"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 7
        }
        action = { type = "expire" }
      },
      {
        rulePriority = 2
        description  = "Keep last 20 tagged images"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["v", "latest", "prod", "sha"]
          countType     = "imageCountMoreThan"
          countNumber   = 20
        }
        action = { type = "expire" }
      }
    ]
  })
}
