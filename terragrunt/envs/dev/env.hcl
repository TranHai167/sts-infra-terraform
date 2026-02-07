locals {
  environment      = "dev"
  region           = "ap-southeast-1"
  account_id       = "344414913751"
  cluster_name     = "eks-sts-central"
  vpc_id           = "vpc-0a696d74362c59600"
  subnet_ids       = ["subnet-0e007a450a832f5d2", "subnet-024a79092851a001b"]
  enable_alb       = true
  enable_karpenter = false
  enable_external_secrets = true

  tags = {
    Project = "sts"
  }
}
