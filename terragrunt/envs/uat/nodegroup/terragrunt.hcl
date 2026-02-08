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
  create          = true
  create_role     = true
  cluster_name    = local.env_config.cluster_name
  node_group_name = local.env_config.nodegroup_name
  subnet_ids      = local.env_config.subnet_ids
  instance_types  = [local.env_config.node_instance_type]
  scaling = {
    desired = local.env_config.node_desired
    min     = local.env_config.node_min
    max     = local.env_config.node_max
  }
  labels = {
    "sts.io/nodegroup" = local.env_config.nodegroup_name
  }
  taints = [
    {
      key    = "sts.io/system"
      value  = "true"
      effect = "NO_SCHEDULE"
    }
  ]
  enable_launch_template = local.env_config.max_pods_per_node > 0
  max_pods               = local.env_config.max_pods_per_node
}
