# --- IAM: control plane role -------------------------------------------
# AKS's `identity { type = "SystemAssigned" }` block auto-creates and
# manages this for you. EKS requires you to define it explicitly.
resource "aws_iam_role" "cluster" {
  for_each = var.kubernetes_clusters
  name     = "${each.key}-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "eks.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = each.value.tags
}

resource "aws_iam_role_policy_attachment" "cluster_policy" {
  for_each   = var.kubernetes_clusters
  role       = aws_iam_role.cluster[each.key].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# --- IAM: node group role ------------------------------------------------
resource "aws_iam_role" "node" {
  for_each = var.kubernetes_clusters
  name     = "${each.key}-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = each.value.tags
}

resource "aws_iam_role_policy_attachment" "node_worker_policy" {
  for_each   = var.kubernetes_clusters
  role       = aws_iam_role.node[each.key].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "node_cni_policy" {
  for_each   = var.kubernetes_clusters
  role       = aws_iam_role.node[each.key].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "node_ecr_readonly" {
  for_each   = var.kubernetes_clusters
  role       = aws_iam_role.node[each.key].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# --- EKS control plane -----------------------------------------------------
resource "aws_eks_cluster" "this" {
  for_each = var.kubernetes_clusters

  name     = each.key
  role_arn = aws_iam_role.cluster[each.key].arn
  version  = each.value.kubernetes_version
  tags     = each.value.tags

  vpc_config {
    subnet_ids              = each.value.subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  depends_on = [aws_iam_role_policy_attachment.cluster_policy]
}

# --- Managed node group (AWS equivalent of AKS's default_node_pool) -------
resource "aws_eks_node_group" "default" {
  for_each = var.kubernetes_clusters

  cluster_name    = aws_eks_cluster.this[each.key].name
  node_group_name = each.value.default_node_pool.name
  node_role_arn   = aws_iam_role.node[each.key].arn
  subnet_ids      = each.value.subnet_ids
  instance_types  = [each.value.default_node_pool.instance_type]
  tags            = each.value.tags

  scaling_config {
    desired_size = each.value.default_node_pool.node_count
    min_size     = each.value.default_node_pool.node_count
    max_size     = each.value.default_node_pool.node_count
  }

  depends_on = [
    aws_iam_role_policy_attachment.node_worker_policy,
    aws_iam_role_policy_attachment.node_cni_policy,
    aws_iam_role_policy_attachment.node_ecr_readonly,
  ]
}
