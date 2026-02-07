# sts-infra-terraform

This repo uses Terragrunt to orchestrate module apply order across environments.

## Layout

- modules: Terraform modules (vpc, eks, iam-irsa, nodegroup, addons-iam)
- terragrunt: per-environment configs and dependency wiring

See [terragrunt/README.md](terragrunt/README.md) for run instructions.

terraform commands:

terraform init --> terraform plan --> terraform apply --> terraform destroy

### Bước 1: Tạo EKS cluster

Tài nguyên tạo ra (AWS):

- EKS Cluster (control plane)
- Security Group cho cluster
- IAM Role cho EKS control plane
- VPC/Subnet/Route Table (nếu VPC được tạo mới)
- EKS Add-ons mặc định (CoreDNS, kube-proxy, VPC CNI) nếu bật

Folder liên quan trong repo:

- [modules/eks](modules/eks)
- [modules/vpc](modules/vpc) (nếu VPC được quản lý bằng Terraform)
- [terragrunt/envs/\*/eks](terragrunt/envs/dev/eks)
- [terragrunt/envs/\*/vpc](terragrunt/envs/dev/vpc)

### Bước 2: Tạo 2 worker node (instance type cụ thể)

Tài nguyên tạo ra (AWS):

- EKS Managed Node Group hoặc Auto Scaling Group
- Launch Template
- IAM Role/Instance Profile cho node
- Security Group cho node (hoặc dùng chung)

Folder liên quan trong repo:

- [modules/nodegroup](modules/nodegroup)
- [terragrunt/envs/\*/nodegroup](terragrunt/envs/dev/nodegroup)

### Bước 4: Tăng số pod tối đa trên node

Tác động:

- Cấu hình kubelet (max pods per node), không tạo tài nguyên AWS mới
- Thường chỉnh qua bootstrap/user data

Folder liên quan trong repo:

- [modules/nodegroup/templates/bootstrap.sh.tpl](modules/nodegroup/templates/bootstrap.sh.tpl)
- [modules/nodegroup](modules/nodegroup)

### Bước 5: Add-ons/IAM cho addon (IRSA)

Tài nguyên tạo ra (AWS/K8s):

- IAM role + policy cho addon
- ServiceAccount có annotation IAM role

Folder liên quan trong repo:

- [modules/addons-iam](modules/addons-iam)
- [modules/iam-irsa](modules/iam-irsa)
- [terragrunt/envs/\*/addons-iam](terragrunt/envs/dev/addons-iam)
- [terragrunt/envs/\*/iam-irsa](terragrunt/envs/dev/iam-irsa)
