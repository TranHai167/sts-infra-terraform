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
  skip_outputs = true
}

inputs = {
  cluster_name = local.env_config.cluster_name
  create_cluster = false
  kubernetes_version = local.env_config.kubernetes_version
  subnet_ids = local.env_config.subnet_ids
  endpoint_private_access = true
  endpoint_public_access  = true
  public_access_cidrs     = ["0.0.0.0/0"]
  cluster_role_name       = "${local.env_config.cluster_name}-cluster-role"
  create_oidc_provider    = false
  authentication_mode     = "API_AND_CONFIG_MAP"
}
