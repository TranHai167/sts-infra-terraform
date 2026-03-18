variable "cluster_name" {
  type        = string
  description = "Existing EKS cluster name."
}

variable "create_cluster" {
  type        = bool
  description = "Whether to create the EKS cluster."
  default     = false
}

variable "kubernetes_version" {
  type        = string
  description = "Kubernetes version for EKS cluster."
  default     = "1.29"
}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnets for the EKS control plane."
  default     = []
}

variable "endpoint_private_access" {
  type        = bool
  description = "Enable private endpoint access."
  default     = true
}

variable "endpoint_public_access" {
  type        = bool
  description = "Enable public endpoint access."
  default     = true
}

variable "public_access_cidrs" {
  type        = list(string)
  description = "Allowed public access CIDRs."
  default     = ["0.0.0.0/0"]
}

variable "cluster_role_name" {
  type        = string
  description = "IAM role name for the EKS cluster."
  default     = ""
}

variable "cluster_role_policy_arns" {
  type        = list(string)
  description = "Explicit IAM policy ARNs for the cluster role. If empty, defaults are used."
  default     = []
}

variable "cluster_role_additional_policy_arns" {
  type        = list(string)
  description = "Additional IAM policy ARNs to attach to the cluster role."
  default     = []
}

variable "create_oidc_provider" {
  type        = bool
  description = "Whether to create the IAM OIDC provider."
  default     = true
}
variable "authentication_mode" {
  type        = string
  description = "EKS authentication mode (API_AND_CONFIG_MAP, CONFIG_MAP, API)."
  default     = "API_AND_CONFIG_MAP"
}
