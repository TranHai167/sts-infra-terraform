variable "create" {
  type        = bool
  description = "Whether to create the node group."
  default     = false
}

variable "cluster_name" {
  type        = string
  description = "EKS cluster name."
  default     = ""
}

variable "node_group_name" {
  type        = string
  description = "Node group name."
  default     = ""
}

variable "node_role_arn" {
  type        = string
  description = "IAM role ARN for nodes."
  default     = ""
}

variable "create_role" {
  type        = bool
  description = "Whether to create the IAM role for nodes."
  default     = true
}

variable "node_role_name" {
  type        = string
  description = "IAM role name for nodes."
  default     = ""
}

variable "node_role_additional_policy_arns" {
  type        = list(string)
  description = "Additional IAM policy ARNs for the node role."
  default     = []
}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnets for the node group."
  default     = []
}

variable "instance_types" {
  type        = list(string)
  description = "EC2 instance types."
  default     = []
}

variable "scaling" {
  type = object({
    desired = number
    min     = number
    max     = number
  })
  description = "Scaling config."
  default = {
    desired = 0
    min     = 0
    max     = 0
  }
}


variable "labels" {
  type        = map(string)
  description = "Kubernetes labels."
  default     = {}
}

variable "taints" {
  type = list(object({
    key    = string
    value  = string
    effect = string
  }))
  description = "Kubernetes taints."
  default     = []
}

variable "enable_launch_template" {
  type        = bool
  description = "Whether to create and attach a launch template."
  default     = false
}

variable "launch_template_name_prefix" {
  type        = string
  description = "Launch template name prefix."
  default     = "eks-ng-"
}

variable "launch_template_version" {
  type        = string
  description = "Launch template version for node group."
  default     = "$Latest"
}

variable "max_pods" {
  type        = number
  description = "Max pods per node. Use 0 to keep default."
  default     = 0
}

variable "bootstrap_extra_args" {
  type        = string
  description = "Extra args passed to /etc/eks/bootstrap.sh."
  default     = ""
}

variable "user_data_override" {
  type        = string
  description = "Override user_data for launch template."
  default     = null
}

variable "launch_template" {
  type = object({
    image_id              = optional(string)
    key_name              = optional(string)
    instance_type         = optional(string)
    security_group_ids    = optional(list(string), [])
    block_device_mappings = optional(list(object({
      device_name = string
      volume_size = number
      volume_type = string
      encrypted   = bool
    })), [])
  })
  description = "Launch template config."
  default = {
    image_id              = null
    key_name              = null
    instance_type         = null
    security_group_ids    = []
    block_device_mappings = []
  }
}
