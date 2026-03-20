locals {
  env_config = read_terragrunt_config(find_in_parent_folders("env.hcl")).locals
  common_tags = merge(local.env_config.tags, {
    Environment = local.env_config.environment
    ManagedBy   = "terragrunt"
  })
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "${local.env_config.region}"

  default_tags {
    tags = ${jsonencode(local.common_tags)}
  }
}
EOF
}
