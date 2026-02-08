variable "cluster_name" {
  type        = string
  description = "EKS cluster name."
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where nodes run."
}

variable "create_role" {
  type        = bool
  description = "Create IAM role for nodes."
  default     = true
}

variable "create_instance_profile" {
  type        = bool
  description = "Create instance profile for nodes."
  default     = true
}

variable "create_security_group" {
  type        = bool
  description = "Create security group tagged for Karpenter discovery."
  default     = true
}

variable "manage_kms_key" {
  type        = bool
  description = "Manage EBS KMS key for node volumes. If false, supply existing key ARN via manifests."
  default     = false
}

variable "kms_key_description" {
  type        = string
  description = "Description for managed KMS key."
  default     = "EBS encryption key for Karpenter-managed nodes"
}

variable "kms_key_alias" {
  type        = string
  description = "Alias name for the managed KMS key (include the 'alias/' prefix)."
  default     = ""
}

variable "role_name" {
  type        = string
  description = "Override IAM role name for nodes."
  default     = ""
}

variable "instance_profile_name" {
  type        = string
  description = "Override instance profile name."
  default     = ""
}

variable "security_group_name" {
  type        = string
  description = "Override security group name."
  default     = ""
}

variable "role_path" {
  type        = string
  description = "Path for IAM role and instance profile."
  default     = "/"
}

variable "node_managed_policy_arns" {
  type        = list(string)
  description = "Managed policy ARNs to attach to the node role."
  default     = [
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]
}

variable "node_additional_policy_arns" {
  type        = list(string)
  description = "Additional policy ARNs to attach to the node role."
  default     = []
}

variable "enable_node_kms_policy" {
  type        = bool
  description = "Whether to create and attach a KMS usage policy for Karpenter nodes."
  default     = false
}

variable "node_kms_key_arn" {
  type        = string
  description = "KMS key ARN for Karpenter node usage policy."
  default     = ""
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to created resources."
  default     = {}
}
