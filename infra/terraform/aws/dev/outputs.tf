output "deployment_target" {
  description = "Cloud deployment target represented by this root."
  value       = "aws"
}

output "environment" {
  description = "Environment represented by this root."
  value       = var.environment
}

output "common_tags" {
  description = "Tags that future AWS modules should apply."
  value       = local.common_tags
}

output "alb_dns_name" {
  description = "Public ALB DNS name. Routes / to frontend and /api/*, /health, /readyz to backend."
  value       = module.alb.dns_name
}

output "ecr_repository_urls" {
  description = "ECR repository URLs for publishing frontend and backend images."
  value       = module.ecr.repository_urls
}

output "ecs_cluster_name" {
  description = "ECS cluster ARN."
  value       = module.cluster.cluster_arn
}
