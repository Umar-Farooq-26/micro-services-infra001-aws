variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "ap-southeast-2" # closest AWS region to the original's australiaeast
}

variable "infra_config" {
  description = "Complete infrastructure configuration for Dev environment"
  type = object({
    vpc = object({
      name                 = string
      cidr_block           = string
      azs                  = list(string)
      public_subnet_cidrs  = list(string)
      private_subnet_cidrs = list(string)
    })
    eks_cluster_tag = string # must match the key used in kubernetes_clusters below

    container_registries = map(object({
      image_tag_mutability = optional(string, "IMMUTABLE")
      scan_on_push         = optional(bool, true)
      force_delete         = optional(bool, false)
      tags                 = optional(map(string), {})
    }))

    kubernetes_clusters = map(object({
      kubernetes_version = optional(string)
      default_node_pool = object({
        name          = string
        node_count    = optional(number, 1)
        instance_type = optional(string, "t3.medium")
      })
      tags = optional(map(string), {})
    }))

    tags = optional(map(string), {})
  })
}
