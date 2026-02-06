# sts-infra-terraform

This repo uses Terragrunt to orchestrate module apply order across environments.

## Layout

- modules: Terraform modules (vpc, eks, iam-irsa, nodegroup, addons-iam)
- terragrunt: per-environment configs and dependency wiring

See [terragrunt/README.md](terragrunt/README.md) for run instructions.
