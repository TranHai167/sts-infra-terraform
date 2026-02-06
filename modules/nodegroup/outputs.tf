output "node_group_name" {
  value       = try(aws_eks_node_group.this[0].node_group_name, null)
  description = "Node group name."
}

output "launch_template_id" {
  value       = try(aws_launch_template.this[0].id, null)
  description = "Launch template ID."
}
