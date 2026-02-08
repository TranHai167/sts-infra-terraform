data "aws_eks_cluster" "this" {
  name = var.cluster_name
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

locals {
  role_name             = var.role_name != "" ? var.role_name : "KarpenterNodeRole-${var.cluster_name}"
  instance_profile_name = var.instance_profile_name != "" ? var.instance_profile_name : local.role_name
  security_group_name   = var.security_group_name != "" ? var.security_group_name : "karpenter-${var.cluster_name}-nodes"
  kms_alias_name        = var.kms_key_alias != "" ? var.kms_key_alias : "alias/${var.cluster_name}-karpenter-ebs"
}

resource "aws_iam_role" "node" {
  count = var.create_role ? 1 : 0

  name = local.role_name
  path = var.role_path

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "managed" {
  for_each = var.create_role ? toset(var.node_managed_policy_arns) : []

  role       = aws_iam_role.node[0].name
  policy_arn = each.value
}

resource "aws_iam_role_policy_attachment" "additional" {
  for_each = var.create_role ? toset(var.node_additional_policy_arns) : []

  role       = aws_iam_role.node[0].name
  policy_arn = each.value
}

resource "aws_iam_role_policy_attachment" "node_kms" {
  count = var.create_role && var.enable_node_kms_policy ? 1 : 0

  role       = aws_iam_role.node[0].name
  policy_arn = aws_iam_policy.node_kms[0].arn
}

resource "aws_iam_policy" "node_kms" {
  count = var.enable_node_kms_policy ? 1 : 0

  name = "KarpenterNodeKms-${var.cluster_name}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowKMSKeyUsage"
        Effect = "Allow"
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:CreateGrant",
          "kms:DescribeKey"
        ]
        Resource = var.node_kms_key_arn
      }
    ]
  })
}

resource "aws_iam_instance_profile" "node" {
  count = var.create_instance_profile ? 1 : 0

  name = local.instance_profile_name
  path = var.role_path
  role = aws_iam_role.node[0].name

  tags = var.tags
}

resource "aws_security_group" "karpenter" {
  count = var.create_security_group ? 1 : 0

  name        = local.security_group_name
  description = "Security group for Karpenter-managed worker nodes"
  vpc_id      = var.vpc_id

  tags = merge(
    {
      "Name"                         : local.security_group_name,
      "karpenter.sh/discovery"       : var.cluster_name,
      "kubernetes.io/cluster/${var.cluster_name}" : "owned"
    },
    var.tags
  )
}

resource "aws_security_group_rule" "self_all" {
  count = var.create_security_group ? 1 : 0

  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.karpenter[0].id
  self              = true
  description       = "Allow all traffic within node SG"
}

resource "aws_security_group_rule" "control_plane_https" {
  count = var.create_security_group ? 1 : 0

  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.karpenter[0].id
  source_security_group_id = data.aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
  description              = "Allow control plane to connect to kubelet"
}

resource "aws_security_group_rule" "control_plane_kubelet" {
  count = var.create_security_group ? 1 : 0

  type                     = "ingress"
  from_port                = 10250
  to_port                  = 10250
  protocol                 = "tcp"
  security_group_id        = aws_security_group.karpenter[0].id
  source_security_group_id = data.aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
  description              = "Allow control plane to kubelet"
}

resource "aws_security_group_rule" "control_plane_nodeport" {
  count = var.create_security_group ? 1 : 0

  type                     = "ingress"
  from_port                = 30000
  to_port                  = 32767
  protocol                 = "tcp"
  security_group_id        = aws_security_group.karpenter[0].id
  source_security_group_id = data.aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
  description              = "Allow control plane to NodePorts"
}

resource "aws_security_group_rule" "egress_all" {
  count = var.create_security_group ? 1 : 0

  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.karpenter[0].id
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  description       = "Allow all egress"
}

resource "aws_kms_key" "ebs" {
  count = var.manage_kms_key ? 1 : 0

  description             = var.kms_key_description
  enable_key_rotation     = true
  multi_region            = false
  deletion_window_in_days = 30
}

resource "aws_kms_alias" "ebs" {
  count         = var.manage_kms_key ? 1 : 0
  name          = local.kms_alias_name
  target_key_id = aws_kms_key.ebs[0].key_id
}

output "node_role_arn" {
  value       = var.create_role ? aws_iam_role.node[0].arn : null
  description = "IAM role ARN for Karpenter-managed nodes"
}

output "instance_profile_name" {
  value       = var.create_instance_profile ? aws_iam_instance_profile.node[0].name : null
  description = "Instance profile for Karpenter-managed nodes"
}

output "security_group_id" {
  value       = var.create_security_group ? aws_security_group.karpenter[0].id : null
  description = "Security group ID tagged for Karpenter discovery"
}

output "kms_key_arn" {
  value       = var.manage_kms_key ? aws_kms_key.ebs[0].arn : null
  description = "KMS key ARN for EBS encryption"
}
