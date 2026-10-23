output "deployment_target" {
  description = "Cloud deployment target represented by this root."
  value       = "azure"
}

output "environment" {
  description = "Environment represented by this root."
  value       = var.environment
}

output "common_tags" {
  description = "Tags that future Azure modules should apply."
  value       = local.common_tags
}
