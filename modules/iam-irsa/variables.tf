variable "oidc_provider_arn" {
  type        = string
  description = "OIDC provider ARN."
}

variable "oidc_provider_url" {
  type        = string
  description = "OIDC provider URL without scheme."
}

variable "roles" {
  type = map(object({
    role_name      = string
    namespace      = string
    service_account = string
    policy_arns    = list(string)
    role_path      = optional(string, "/")
  }))
  description = "IRSA roles to create."
}
