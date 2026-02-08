include "common" {
  path = find_in_parent_folders("common.hcl")
}

locals {
  env_config = read_terragrunt_config(find_in_parent_folders("env.hcl")).locals
}

terraform {
  source = "../../../../modules/addons-iam"
}

dependency "eks" {
  config_path = "../eks"
  skip_outputs = true
}

inputs = {
  cluster_name            = local.env_config.cluster_name
  enable_alb_policy       = local.env_config.enable_alb
  enable_karpenter_policy = local.env_config.enable_karpenter
  enable_external_secrets_policy = local.env_config.enable_external_secrets
}
