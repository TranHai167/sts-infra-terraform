output "cluster_name" {
  value       = local.cluster.name
  description = "EKS cluster name."
}

output "cluster_endpoint" {
  value       = local.cluster.endpoint
  description = "EKS cluster endpoint."
}

output "oidc_provider_arn" {
  value       = var.create_oidc_provider ? aws_iam_openid_connect_provider.this[0].arn : data.aws_iam_openid_connect_provider.this[0].arn
  description = "OIDC provider ARN."
}

output "oidc_provider_url" {
  value       = replace(local.cluster.identity[0].oidc[0].issuer, "https://", "")
  description = "OIDC provider URL without scheme."
}

output "cluster_role_arn" {
  value       = var.create_cluster ? aws_iam_role.cluster[0].arn : null
  description = "EKS cluster IAM role ARN if created."
}
