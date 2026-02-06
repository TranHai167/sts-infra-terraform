include "common" {
  path = find_in_parent_folders("common.hcl")
}

locals {
  env_config = read_terragrunt_config(find_in_parent_folders("env.hcl")).locals
}

terraform {
  source = "../../../../modules/vpc"
}

inputs = {
  vpc_id     = local.env_config.vpc_id
  subnet_ids = local.env_config.subnet_ids
}
