include "common" {
  path = find_in_parent_folders("common.hcl")
}

locals {
  env_config = read_terragrunt_config(find_in_parent_folders("env.hcl")).locals
}

terraform {
  source = "../../../../modules/eks"
}

dependency "vpc" {
  config_path = "../vpc"
}

inputs = {
  cluster_name = local.env_config.cluster_name
  create_cluster = false
  create_oidc_provider = false
}
