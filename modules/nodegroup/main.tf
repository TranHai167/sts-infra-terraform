locals {
  node_role_name = var.node_role_name != "" ? var.node_role_name : "${var.cluster_name}-${var.node_group_name}-node-role"
  node_role_arn  = var.create_role ? aws_iam_role.node[0].arn : var.node_role_arn
  user_data_base64 = var.enable_launch_template ? (
    var.user_data_override != null ? base64encode(var.user_data_override) : (
      var.max_pods > 0 ? base64encode(templatefile("${path.module}/templates/bootstrap.sh.tpl", {
        cluster_name = var.cluster_name
        max_pods     = var.max_pods
        extra_args   = var.bootstrap_extra_args
      })) : null
    )
  ) : null
}

resource "aws_iam_role" "node" {
  count = var.create && var.create_role ? 1 : 0

  name = local.node_role_name

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
}

resource "aws_iam_role_policy_attachment" "node" {
  for_each = var.create && var.create_role ? {
    worker     = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
    cni        = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
    ecr        = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
    ecr_pull   = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly"
    ssm        = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    ebs_csi    = "arn:aws:iam::aws:policy/AmazonEBSCSIDriverPolicy"
    efs_csi    = "arn:aws:iam::aws:policy/AmazonEFSCIDriverPolicy"
    secrets_rw = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
  } : {}

  role       = aws_iam_role.node[0].name
  policy_arn = each.value
}

resource "aws_iam_role_policy_attachment" "node_additional" {
  for_each = var.create && var.create_role ? { for arn in var.node_role_additional_policy_arns : arn => arn } : {}

  role       = aws_iam_role.node[0].name
  policy_arn = each.value
}

resource "aws_launch_template" "this" {
  count = var.enable_launch_template ? 1 : 0

  name_prefix   = var.launch_template_name_prefix
  image_id      = var.launch_template.image_id
  user_data     = local.user_data_base64
  key_name      = var.launch_template.key_name
  instance_type = var.launch_template.instance_type

  vpc_security_group_ids = var.launch_template.security_group_ids

  dynamic "block_device_mappings" {
    for_each = var.launch_template.block_device_mappings

    content {
      device_name = block_device_mappings.value.device_name

      ebs {
        volume_size = block_device_mappings.value.volume_size
        volume_type = block_device_mappings.value.volume_type
        encrypted   = block_device_mappings.value.encrypted
      }
    }
  }
}

resource "aws_eks_node_group" "this" {
  count = var.create ? 1 : 0

  cluster_name    = var.cluster_name
  node_group_name = var.node_group_name
  node_role_arn   = local.node_role_arn
  subnet_ids      = var.subnet_ids
  instance_types  = var.instance_types

  scaling_config {
    desired_size = var.scaling.desired
    min_size     = var.scaling.min
    max_size     = var.scaling.max
  }

  labels = var.labels

  dynamic "taint" {
    for_each = var.taints

    content {
      key    = taint.value.key
      value  = taint.value.value
      effect = taint.value.effect
    }
  }

  dynamic "launch_template" {
    for_each = var.enable_launch_template ? [1] : []

    content {
      id      = aws_launch_template.this[0].id
      version = var.launch_template_version
    }
  }

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }

  depends_on = [aws_iam_role_policy_attachment.node, aws_iam_role_policy_attachment.node_additional]
}
