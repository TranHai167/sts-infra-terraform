output "vpc_id" {
  value       = data.aws_vpc.this.id
  description = "VPC ID."
}

output "vpc_cidr_block" {
  value       = data.aws_vpc.this.cidr_block
  description = "VPC CIDR block."
}

output "subnet_ids" {
  value       = [for subnet in data.aws_subnet.this : subnet.id]
  description = "Subnet IDs."
}

output "subnet_azs" {
  value       = [for subnet in data.aws_subnet.this : subnet.availability_zone]
  description = "Subnet availability zones."
}
