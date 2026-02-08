# sts-infra-terraform

Repo này dùng Terragrunt để điều phối thứ tự apply các module Terraform theo môi trường.

## Yêu cầu

- Terraform
- Terragrunt
- AWS CLI
- kubectl (nếu muốn thao tác với EKS)

Xem thêm hướng dẫn chạy trong [terragrunt/README.md](terragrunt/README.md).

## Cấu trúc thư mục

- [modules](modules): các module Terraform (vpc, eks, iam-irsa, nodegroup, addons-iam, karpenter-support)
- [terragrunt](terragrunt): cấu hình theo môi trường và wiring dependency

## Cấu hình môi trường

Mỗi môi trường có file env riêng, ví dụ:

- [terragrunt/envs/uat/env.hcl](terragrunt/envs/uat/env.hcl)

Các biến chính thường chỉnh:

- tên cluster, VPC, subnet
- phiên bản Kubernetes
- instance type, số lượng node
- bật/tắt các addon (ALB, External Secrets, Karpenter)

## Các bước triển khai (từng bước một)

### Bước 1: VPC (nếu quản lý bằng Terraform)

Tài nguyên tạo ra (AWS):

- VPC, Subnet, Route Table (hoặc đọc từ VPC có sẵn nếu chỉ data source)

Folder liên quan:

- [modules/vpc](modules/vpc)
- [terragrunt/envs/\*/vpc](terragrunt/envs/uat/vpc)

### Bước 2: Tạo EKS cluster

Tài nguyên tạo ra (AWS):

- EKS Cluster (control plane)
- Security Group cho cluster
- IAM Role cho EKS control plane
- OIDC provider (nếu bật)

Folder liên quan:

- [modules/eks](modules/eks)
- [terragrunt/envs/\*/eks](terragrunt/envs/uat/eks)

### Bước 3: Add-ons IAM policies

Tài nguyên tạo ra (AWS):

- IAM Policy cho ALB, Karpenter controller, External Secrets (tuỳ bật)

Folder liên quan:

- [modules/addons-iam](modules/addons-iam)
- [terragrunt/envs/\*/addons-iam](terragrunt/envs/uat/addons-iam)

### Bước 4: IAM IRSA cho add-ons

Tài nguyên tạo ra (AWS/K8s):

- IAM Role cho ServiceAccount (IRSA)
- Attach policy cho từng addon

Folder liên quan:

- [modules/iam-irsa](modules/iam-irsa)
- [terragrunt/envs/\*/iam-irsa](terragrunt/envs/uat/iam-irsa)

### Bước 5: Karpenter hỗ trợ node (tuỳ chọn)

Tài nguyên tạo ra (AWS):

- IAM Role cho Karpenter node
- Instance Profile
- Security Group
- KMS key/alias (nếu bật)

Folder liên quan:

- [modules/karpenter-support](modules/karpenter-support)
- [terragrunt/envs/\*/karpenter-support](terragrunt/envs/uat/karpenter-support)

### Bước 6: Node group (Managed nodegroup)

Tài nguyên tạo ra (AWS):

- EKS Managed Node Group
- Launch Template (nếu bật)
- IAM Role/Instance Profile cho node

Folder liên quan:

- [modules/nodegroup](modules/nodegroup)
- [modules/nodegroup/templates/bootstrap.sh.tpl](modules/nodegroup/templates/bootstrap.sh.tpl)
- [terragrunt/envs/\*/nodegroup](terragrunt/envs/uat/nodegroup)

## Trình tự chạy khuyến nghị (UAT)

Chạy lần lượt từng module, mỗi module init -> plan -> apply:

```powershell
cd terragrunt/envs/uat/vpc
terragrunt init
terragrunt plan
terragrunt apply

cd ..\eks
terragrunt init
terragrunt plan
terragrunt apply

cd ..\addons-iam
terragrunt init
terragrunt plan
terragrunt apply

cd ..\iam-irsa
terragrunt init
terragrunt plan
terragrunt apply

cd ..\karpenter-support
terragrunt init
terragrunt plan
terragrunt apply

cd ..\nodegroup
terragrunt init
terragrunt plan
terragrunt apply
```

## Kết nối kubectl tới EKS

Lưu ý config aws profile trước.

```powershell
$env:AWS_PROFILE="sts-uat"
aws eks update-kubeconfig --region ap-southeast-1 --name non-prod-eks-sts
kubectl get nodes
kubectl get ns
```

## Ghi chú về import tài nguyên có sẵn

Nếu tài nguyên IAM đã tồn tại, cần import vào state trước khi apply để tránh lỗi trùng tên.
Ví dụ import role IRSA:

```powershell
terragrunt --% import aws_iam_role.this["external_secrets"] arn:aws:iam::344414913751:role/external-secrets-role
```
