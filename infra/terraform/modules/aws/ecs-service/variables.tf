variable "name" {
  description = "ECS service and task definition name."
  type        = string
}

variable "cluster_arn" {
  description = "ECS cluster ARN."
  type        = string
}

variable "image" {
  description = "Container image URI and tag or digest."
  type        = string
}

variable "container_port" {
  description = "Container port."
  type        = number
}

variable "cpu" {
  description = "Fargate CPU units."
  type        = number
  default     = 256
}

variable "memory" {
  description = "Fargate memory in MiB."
  type        = number
  default     = 512
}

variable "desired_count" {
  description = "Development task count."
  type        = number
  default     = 1
}

variable "subnet_ids" {
  description = "Subnet IDs for ECS tasks."
  type        = list(string)
}

variable "security_group_ids" {
  description = "Security groups for ECS tasks."
  type        = list(string)
}

variable "assign_public_ip" {
  description = "Assign public IPs to tasks. Use false with private subnets and NAT."
  type        = bool
  default     = true
}

variable "target_group_arn" {
  description = "ALB target group ARN."
  type        = string
}

variable "environment" {
  description = "Non-sensitive container environment variables."
  type        = map(string)
  default     = {}
}

variable "secrets" {
  description = "Secrets Manager values injected into the container."
  type = list(object({
    name       = string
    value_from = string
  }))
  default = []
}

variable "secret_arns" {
  description = "Secrets Manager ARNs readable by the task execution role."
  type        = list(string)
  default     = []
}

variable "health_check_command" {
  description = "ECS container health check command."
  type        = list(string)
}

variable "log_group_name" {
  description = "CloudWatch log group name."
  type        = string
}

variable "aws_region" {
  description = "AWS region used by the awslogs driver."
  type        = string
}

variable "tags" {
  description = "Tags applied to ECS and IAM resources."
  type        = map(string)
  default     = {}
}
