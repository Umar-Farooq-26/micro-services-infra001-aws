aws_region = "ap-southeast-2"

infra_config = {
  vpc = {
    name                 = "vpc-micro-dev"
    cidr_block           = "10.0.0.0/16"
    azs                  = ["ap-southeast-2a", "ap-southeast-2b"]
    public_subnet_cidrs  = ["10.0.0.0/24", "10.0.1.0/24"]
    private_subnet_cidrs = ["10.0.10.0/24", "10.0.11.0/24"]
  }

  eks_cluster_tag = "eks-micro-dev"

  tags = {
    Environment = "Dev"
    ManagedBy   = "Terraform"
  }

  container_registries = {
    # Original ACR name "acrmicrodev556677" -> ECR repo name (ECR allows
    # lowercase/hyphens, so this is renamed to fit ECR's naming rules).
    "micro-dev" = {
      image_tag_mutability = "MUTABLE" # original ACR had sku="Basic", admin_enabled defaulted false -- MUTABLE is the closer dev-friendly default
      scan_on_push         = true
      force_delete         = true # convenience for a dev environment; remove for prod
      tags = {
        Environment = "Dev"
        ManagedBy   = "Terraform"
      }
    }
  }

  kubernetes_clusters = {
    "eks-micro-dev" = {
      default_node_pool = {
        name          = "default"
        node_count    = 1
        instance_type = "t3.medium" # closest AWS equivalent to the original's Standard_B2s (2 vCPU / 4GB burstable)
      }
      tags = {
        Environment = "Dev"
        ManagedBy   = "Terraform"
      }
    }
  }
}
