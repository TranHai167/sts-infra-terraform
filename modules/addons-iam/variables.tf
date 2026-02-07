variable "cluster_name" {
  type        = string
  description = "EKS cluster name."
}

variable "enable_alb_policy" {
  type        = bool
  description = "Create ALB controller policy."
  default     = true
}

variable "enable_karpenter_policy" {
  type        = bool
  description = "Create Karpenter controller policy."
  default     = false
}

variable "enable_external_secrets_policy" {
  type        = bool
  description = "Create External Secrets controller policy."
  default     = false
}

variable "ebs_policy_arn" {
  type        = string
  description = "EBS CSI policy ARN."
  default     = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}
