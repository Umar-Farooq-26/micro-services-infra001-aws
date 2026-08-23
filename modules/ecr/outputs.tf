output "ecr_ids" {
  value = { for k, v in aws_ecr_repository.this : k => v.id }
}

# AWS equivalent of ACR's "login_server" -- the registry endpoint used
# for `docker push`/`docker pull`.
output "ecr_repository_urls" {
  value = { for k, v in aws_ecr_repository.this : k => v.repository_url }
}
