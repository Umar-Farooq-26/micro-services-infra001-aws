output "eks_ids" {
  value = { for k, v in aws_eks_cluster.this : k => v.id }
}

output "eks_cluster_endpoints" {
  value = { for k, v in aws_eks_cluster.this : k => v.endpoint }
}

# AWS equivalent of AKS's "aks_kube_configs" output. EKS doesn't hand back
# a ready-made kubeconfig blob the way AKS does -- you generate it locally
# with the AWS CLI instead: `aws eks update-kubeconfig --name <cluster-name>`.
# This output gives you the exact command per cluster.
output "eks_kubeconfig_commands" {
  value = { for k, v in aws_eks_cluster.this : k => "aws eks update-kubeconfig --name ${v.name} --region ${data.aws_region.current.name}" }
}

data "aws_region" "current" {}
