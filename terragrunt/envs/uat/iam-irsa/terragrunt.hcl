include "common" {
  path = find_in_parent_folders("common.hcl")
}

locals {
  env_config = read_terragrunt_config(find_in_parent_folders("env.hcl")).locals
}

terraform {
  source = "../../../../modules/iam-irsa"
}

dependency "eks" {
  config_path = "../eks"
}

dependency "addons_iam" {
  config_path = "../addons-iam"
}

inputs = {
  oidc_provider_arn = dependency.eks.outputs.oidc_provider_arn
  oidc_provider_url = dependency.eks.outputs.oidc_provider_url
  roles = merge(
    local.env_config.enable_alb ? {
      alb_controller = {
        role_name       = "${local.env_config.cluster_name}-aws-load-balancer-controller"
        namespace       = "kube-system"
        service_account = "aws-load-balancer-controller"
        policy_arns     = [dependency.addons_iam.outputs.alb_policy_arn]
      }
    } : {},
    {
      ebs_csi_controller = {
        role_name       = "${local.env_config.cluster_name}-ebs-csi-controller"
        namespace       = "kube-system"
        service_account = "ebs-csi-controller-sa"
        policy_arns     = [dependency.addons_iam.outputs.ebs_policy_arn]
      }
      ebs_csi_node = {
        role_name       = "${local.env_config.cluster_name}-ebs-csi-node"
        namespace       = "kube-system"
        service_account = "ebs-csi-node-sa"
        policy_arns     = [dependency.addons_iam.outputs.ebs_policy_arn]
      }
    },
    local.env_config.enable_external_secrets ? {
      external_secrets = {
        role_name       = "external-secrets-role"
        role_path       = "/eks/"
        namespace       = "external-secrets"
        service_account = "external-secrets"
        policy_arns     = [dependency.addons_iam.outputs.external_secrets_policy_arn]
      }
    } : {},
    local.env_config.enable_karpenter ? {
      karpenter_controller = {
        role_name       = "KarpenterControllerRole-${local.env_config.cluster_name}"
        namespace       = "karpenter"
        service_account = "karpenter"
        policy_arns     = [dependency.addons_iam.outputs.karpenter_policy_arn]
      }
    } : {}
  )
}
