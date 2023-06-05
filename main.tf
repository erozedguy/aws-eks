# EKS Cluster
resource "aws_eks_cluster" "eks_cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.EKSClusterRole.arn
  version  = var.cluster_version

  vpc_config {
    subnet_ids              = flatten([var.subnets_id.private_subnets_id, var.subnets_id.public_subnets_id])
    security_group_ids      = var.cluster_security_group_id
    endpoint_private_access = var.endpoint_private_access
    endpoint_public_access  = var.endpoint_public_access
    public_access_cidrs     = var.public_access_cidrs
  }

  enabled_cluster_log_types = var.cluster_logs_types

  dynamic "encryption_config" {
    for_each = var.cluster_encryption.enable ? [var.cluster_encryption.resources] : []
    content {
      provider {
        key_arn = var.cluster_encryption.key_arn
      }
      resources = encryption_config.value
    }
  }

  dynamic "kubernetes_network_config" {
    for_each = { networking = var.cluster_networking }
    content {
      service_ipv4_cidr = kubernetes_network_config.value.service_cidr
      ip_family         = kubernetes_network_config.value.ip_family
    }
  }

  tags = {
    "name" = "eks-dev-us-east-1"
  }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy
  ]

}

# # NODE GROUP
resource "aws_eks_node_group" "node_ec2" {
  for_each        = { for node_group in var.node_groups : node_group.name => node_group }
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = each.value.name
  node_role_arn   = aws_iam_role.NodeGroupRole.arn
  subnet_ids      = var.subnets_id.private_subnets_id
  version         = each.value.k8s_version

  scaling_config {
    desired_size = try(each.value.scaling_config.desired_size, 2)
    max_size     = try(each.value.scaling_config.max_size, 3)
    min_size     = try(each.value.scaling_config.min_size, 1)
  }

  update_config {
    max_unavailable = try(each.value.update_config.max_unavailable, 1)
  }

  ami_type       = each.value.ami_type
  instance_types = each.value.instance_types
  capacity_type  = each.value.capacity_type
  disk_size      = each.value.disk_size

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy
  ]
}

# Add-ons
# resource "aws_eks_addon" "addons" {
#   for_each          = { for addon in var.addons : addon.name => addon }
#   cluster_name      = aws_eks_cluster.eks_cluster.id
#   addon_name        = each.value.name
#   addon_version     = each.value.version
#   resolve_conflicts = "OVERWRITE"
# }

# resource "aws_iam_openid_connect_provider" "default" {
#   url             = "https://${local.oidc}"
#   client_id_list  = ["sts.amazonaws.com"]
#   thumbprint_list = ["9e99a48a9960b14926bb7f3b02e22da2b0ab7280"]
# }