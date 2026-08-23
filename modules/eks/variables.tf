variable "kubernetes_clusters" {
  description = "Map of EKS clusters to create"
  type = map(object({
    subnet_ids         = list(string) # from the vpc module -- AKS has no equivalent, network is implicit there
    kubernetes_version = optional(string)
    tags               = optional(map(string), {})

    default_node_pool = object({
      name          = string
      node_count    = optional(number, 1)
      instance_type = optional(string, "t3.medium") # AWS equivalent of AKS's vm_size
    })
  }))
}
