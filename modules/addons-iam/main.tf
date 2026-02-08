resource "aws_iam_policy" "alb" {
  count  = var.enable_alb_policy ? 1 : 0
  name   = "${var.cluster_name}-aws-load-balancer-controller"
  policy = file("${path.module}/policies/aws-load-balancer-controller.json")
}

resource "aws_iam_policy" "karpenter" {
  count  = var.enable_karpenter_policy ? 1 : 0
  name   = "${var.cluster_name}-karpenter-controller"
  policy = file("${path.module}/policies/karpenter-controller.json")
}

resource "aws_iam_policy" "external_secrets" {
  count  = var.enable_external_secrets_policy ? 1 : 0
  name   = "${var.cluster_name}-external-secrets"
  policy = file("${path.module}/policies/external-secrets.json")
}
