output "dev_vpc_id" {
  value = module.vpc.vpc_id
}

# AWS equivalent of the original "dev_resource_group_ids" -- there's no
# resource-group concept, so the closest useful parallel is the VPC + subnets
# that now scope this environment's networked resources.
output "dev_private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}

output "dev_ecr_repository_urls" {
  value = module.ecr.ecr_repository_urls
}

output "dev_eks_ids" {
  value = module.eks.eks_ids
}

output "dev_eks_kubeconfig_commands" {
  value = module.eks.eks_kubeconfig_commands
}
