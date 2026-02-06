variable "vpc_id" {
  type        = string
  description = "Existing VPC ID."
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of existing subnet IDs."
  default     = []
}
