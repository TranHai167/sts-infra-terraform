variable "description" {
  type        = string
  description = "Description for the KMS key"
}

variable "alias_name" {
  type        = string
  description = "Alias name including alias/ prefix (e.g. alias/my-key)"
}

variable "deletion_window_in_days" {
  type        = number
  description = "Duration in days after which the key is deleted after destruction (7-30)"
  default     = 30
}

variable "enable_key_rotation" {
  type        = bool
  description = "Enable automatic key rotation"
  default     = true
}

variable "multi_region" {
  type        = bool
  description = "Whether to create a multi-region key"
  default     = false
}

variable "policy" {
  type        = string
  description = "Key policy JSON. If null, AWS default policy is used."
  default     = null
}
