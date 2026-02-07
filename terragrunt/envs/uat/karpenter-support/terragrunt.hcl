include "common" {
  path = find_in_parent_folders("common.hcl")
}

locals {
  env_config = read_terragrunt_config(find_in_parent_folders("env.hcl")).locals
}

terraform {
  source = "../../../../modules/karpenter-support"
}

dependency "eks" {
  config_path = "../eks"
}

inputs = {
  cluster_name           = local.env_config.cluster_name
  vpc_id                 = local.env_config.vpc_id
  role_name              = "KarpenterNodeRole-${local.env_config.cluster_name}"
  role_path              = "/eks/"
  instance_profile_name  = "KarpenterNodeRole-${local.env_config.cluster_name}"
  security_group_name    = "${local.env_config.cluster_name}-karpenter-nodes"
  create_role            = true
  create_instance_profile = true
  create_security_group  = true
  manage_kms_key         = true
  kms_key_alias          = "alias/${local.env_config.cluster_name}-karpenter-ebs"
  tags                   = local.env_config.tags
}
