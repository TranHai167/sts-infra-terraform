# Terragrunt layout

This layout splits environments and wires module dependencies.

## Structure

- envs/dev
  - vpc
  - eks
  - addons-iam
  - iam-irsa
  - nodegroup
- envs/uat
  - vpc
  - eks
  - addons-iam
  - iam-irsa
  - nodegroup

## Configure

Edit env files:

- envs/dev/env.hcl
- envs/uat/env.hcl

## Run

From an environment folder:

```bash
cd terragrunt/envs/dev
terragrunt run-all plan
terragrunt run-all apply
```

## Dependency chain

- vpc -> eks -> addons-iam -> iam-irsa -> nodegroup
