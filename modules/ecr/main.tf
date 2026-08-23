resource "aws_ecr_repository" "this" {
  for_each = var.container_registries

  name                 = each.key
  image_tag_mutability = each.value.image_tag_mutability
  force_delete         = each.value.force_delete
  tags                 = each.value.tags

  image_scanning_configuration {
    scan_on_push = each.value.scan_on_push
  }
}

# ACR's "admin_enabled" (static admin credentials) has no direct ECR
# equivalent -- ECR always authenticates via IAM (e.g. `aws ecr get-login-password`),
# which is the AWS-native, more secure pattern anyway. No resource needed here.

resource "aws_ecr_lifecycle_policy" "this" {
  for_each   = var.container_registries
  repository = aws_ecr_repository.this[each.key].name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Expire untagged images older than 14 days"
      selection = {
        tagStatus   = "untagged"
        countType   = "sinceImagePushed"
        countUnit   = "days"
        countNumber = 14
      }
      action = { type = "expire" }
    }]
  })
}
