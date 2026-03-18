data "aws_eks_cluster" "this" {
  count = var.create_cluster ? 0 : 1
  name  = var.cluster_name
}

resource "aws_iam_role" "cluster" {
  count = var.create_cluster ? 1 : 0

  name = local.cluster_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
    lifecycle {
      prevent_destroy = true
      ignore_changes = [name]
    }
}

resource "aws_iam_role_policy_attachment" "cluster" {
  for_each = var.create_cluster ? { for arn in local.cluster_role_policy_arns : arn => arn } : {}

  role       = aws_iam_role.cluster[0].name
  policy_arn = each.value
}

resource "aws_eks_cluster" "this" {
  count = var.create_cluster ? 1 : 0

  name     = var.cluster_name
  role_arn = aws_iam_role.cluster[0].arn
  version  = var.kubernetes_version

  vpc_config {
    subnet_ids              = var.subnet_ids
    endpoint_private_access = var.endpoint_private_access
    endpoint_public_access  = var.endpoint_public_access
    public_access_cidrs     = var.public_access_cidrs
  }

    access_config {
      authentication_mode = var.authentication_mode
    }

  depends_on = [aws_iam_role_policy_attachment.cluster]
}

data "tls_certificate" "oidc" {
  count = var.create_oidc_provider ? 1 : 0
  url   = local.cluster_oidc_issuer
}

resource "aws_iam_openid_connect_provider" "this" {
  count = var.create_oidc_provider ? 1 : 0

  url             = local.cluster_oidc_issuer
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.oidc[0].certificates[0].sha1_fingerprint]
}

resource "aws_eks_access_entry" "karpenter_node" {
  count         = var.create_cluster && (var.authentication_mode == "API" || var.authentication_mode == "API_AND_CONFIG_MAP") ? 1 : 0
  cluster_name  = var.cluster_name
  principal_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/eks/KarpenterNodeRole-${var.cluster_name}"
  type          = "EC2_LINUX"
}

data "aws_caller_identity" "current" {}

data "aws_iam_openid_connect_provider" "this" {
  count = var.create_oidc_provider ? 0 : 1
  url   = local.cluster_oidc_issuer
}

locals {
  cluster                = var.create_cluster ? aws_eks_cluster.this[0] : data.aws_eks_cluster.this[0]
  cluster_oidc_issuer    = local.cluster.identity[0].oidc[0].issuer
  cluster_role_name      = var.cluster_role_name != "" ? var.cluster_role_name : "${var.cluster_name}-cluster-role"
  default_role_policies  = [
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  ]
  cluster_role_policy_arns = length(var.cluster_role_policy_arns) > 0 ? var.cluster_role_policy_arns : concat(
    local.default_role_policies,
    var.cluster_role_additional_policy_arns
  )
}
