locals {
  environment      = "uat"
  region           = "ap-southeast-1"
  account_id       = "344414913751"
  cluster_name     = "non-prod-eks-sts"
  vpc_id           = "vpc-0a696d74362c59600"
  subnet_ids       = ["subnet-024a79092851a001b", "subnet-0e007a450a832f5d2"]
  kubernetes_version = "1.33"
  nodegroup_name     = "managed-ng-eks"
  node_instance_type = "t3.medium"
  node_desired       = 2
  node_min           = 2
  node_max           = 2
  max_pods_per_node  = 21
  enable_alb       = true
  enable_karpenter = false

  tags = {
    Project = "sts"
  }
}
