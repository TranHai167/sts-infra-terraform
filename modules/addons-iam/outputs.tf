output "alb_policy_arn" {
  value       = try(aws_iam_policy.alb[0].arn, null)
  description = "ALB controller policy ARN."
}

output "karpenter_policy_arn" {
  value       = try(aws_iam_policy.karpenter[0].arn, null)
  description = "Karpenter controller policy ARN."
}

output "ebs_policy_arn" {
  value       = var.ebs_policy_arn
  description = "EBS CSI policy ARN."
}

output "external_secrets_policy_arn" {
  value       = try(aws_iam_policy.external_secrets[0].arn, null)
  description = "External Secrets controller policy ARN."
}
