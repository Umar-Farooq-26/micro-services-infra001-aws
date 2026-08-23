variable "name" {
  description = "Name prefix for all VPC resources"
  type        = string
}

variable "cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "azs" {
  description = "Availability zones to spread subnets across (EKS requires at least 2)"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets (one per entry, cycled across azs)"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets (one per entry, cycled across azs)"
  type        = list(string)
}

variable "eks_cluster_tag" {
  description = "Name of the EKS cluster that will use these subnets (used for the required kubernetes.io/cluster/<name> discovery tag)"
  type        = string
}

variable "tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}
