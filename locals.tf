# data "aws_caller_identity" "current" {}

# data "aws_region" "current" {}

# data "aws_eks_cluster" "eks-cluster" {
#   name = aws_eks_cluster.eks-cluster.name
# }

# locals {
#   oidc = trimprefix(data.aws_eks_cluster.eks-cluster.identity[0].oidc[0].issuer, "https://")
# }

# Encryptation
locals {
  cluster_encryption_enable         = var.cluster_encryption.enable
  cluster_encryption_enable_key_arn = var.cluster_encryption.key_arn
  cluster_encryption_config         = var.cluster_encryption.resources
}