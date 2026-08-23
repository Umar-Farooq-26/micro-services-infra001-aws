# AWS has no direct equivalent of an Azure "resource group" (a pure logical
# container with no infra of its own) -- resources are just tagged and
# scoped by IAM/region instead. What AWS EKS *does* need, which AKS handles
# for you implicitly, is real network infrastructure: a VPC, public/private
# subnets, an Internet Gateway, and a NAT Gateway. That's this first module.
module "vpc" {
  source               = "../../modules/vpc"
  name                 = var.infra_config.vpc.name
  cidr_block           = var.infra_config.vpc.cidr_block
  azs                  = var.infra_config.vpc.azs
  public_subnet_cidrs  = var.infra_config.vpc.public_subnet_cidrs
  private_subnet_cidrs = var.infra_config.vpc.private_subnet_cidrs
  eks_cluster_tag      = var.infra_config.eks_cluster_tag
  tags                 = var.infra_config.tags
}

module "ecr" {
  source = "../../modules/ecr"
  container_registries = {
    for k, v in var.infra_config.container_registries : k => {
      image_tag_mutability = v.image_tag_mutability
      scan_on_push         = v.scan_on_push
      force_delete         = v.force_delete
      tags                 = v.tags
    }
  }
}

module "eks" {
  source = "../../modules/eks"
  kubernetes_clusters = {
    for k, v in var.infra_config.kubernetes_clusters : k => {
      subnet_ids         = module.vpc.private_subnet_ids
      kubernetes_version = v.kubernetes_version
      default_node_pool  = v.default_node_pool
      tags               = v.tags
    }
  }
}
