variable "name" {
  description = "Application load balancer name."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID."
  type        = string
}

variable "subnet_ids" {
  description = "Public subnet IDs for the ALB."
  type        = list(string)
}

variable "security_group_id" {
  description = "ALB security group ID."
  type        = string
}

variable "frontend_port" {
  description = "Frontend target port."
  type        = number
  default     = 80
}

variable "backend_port" {
  description = "Backend target port."
  type        = number
  default     = 5000
}

variable "tags" {
  description = "Tags applied to load balancer resources."
  type        = map(string)
  default     = {}
}
