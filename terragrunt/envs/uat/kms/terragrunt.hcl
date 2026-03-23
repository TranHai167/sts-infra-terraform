include "common" {
  path = find_in_parent_folders("common.hcl")
}

locals {
  env_config = read_terragrunt_config(find_in_parent_folders("env.hcl")).locals
}

terraform {
  source = "../../../../modules/kms"
}

inputs = {
  alias_name              = "alias/alias/non-prod-sts-eks"
  description             = "KMS key for non-prod STS EKS cluster"
  deletion_window_in_days = 30
  enable_key_rotation     = true
  multi_region            = false
}
