include "common" {
  path = find_in_parent_folders("common.hcl")
}

locals {
  env_config = read_terragrunt_config(find_in_parent_folders("env.hcl")).locals
}

terraform {
  source = "../../../../modules/nodegroup"
}

dependency "eks" {
  config_path = "../eks"
}

inputs = {
  create          = false
  cluster_name    = local.env_config.cluster_name
  node_group_name = ""
  node_role_arn   = ""
  subnet_ids      = local.env_config.subnet_ids
  instance_types  = []
  scaling = {
    desired = 0
    min     = 0
    max     = 0
  }
}
