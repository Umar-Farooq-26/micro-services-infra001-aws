variable "container_registries" {
  description = "Map of ECR repositories to create"
  type = map(object({
    image_tag_mutability = optional(string, "IMMUTABLE") # ACR default admin_enabled=false maps conceptually to "don't allow overwriting tags"
    scan_on_push          = optional(bool, true)
    force_delete          = optional(bool, false)
    tags                  = optional(map(string), {})
  }))
}
