variable "project_name" {
  description = "Stable project identifier used for future AWS resource names."
  type        = string
  default     = "smart-education-platform"
}

variable "environment" {
  description = "Deployment environment name."
  type        = string
  default     = "dev"
}

variable "aws_region" {
  description = "AWS region for the development environment."
  type        = string
}

variable "container_images" {
  description = "ECR image references for the frontend and backend."
  type = object({
    frontend = string
    backend  = string
  })
}

variable "mongo_uri_secret_arn" {
  description = "Secrets Manager ARN containing the MongoDB URI. Create it outside this stack."
  type        = string
  sensitive   = true
  default     = null
}

variable "frontend_origin" {
  description = "Public frontend origin allowed by the backend CORS policy."
  type        = string
  default     = ""
}

variable "vpc_cidr" {
  description = "Development VPC CIDR."
  type        = string
  default     = "10.42.0.0/16"
}

variable "availability_zones" {
  description = "AWS availability zones for the development VPC."
  type        = list(string)
  default     = []
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDRs, one per availability zone."
  type        = list(string)
  default     = ["10.42.1.0/24", "10.42.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDRs, one per availability zone."
  type        = list(string)
  default     = ["10.42.11.0/24", "10.42.12.0/24"]
}

variable "enable_nat_gateway" {
  description = "Create one NAT gateway for private subnet egress. Disabled by default to avoid development cost."
  type        = bool
  default     = false
}

variable "use_private_subnets" {
  description = "Place ECS tasks in private subnets. Requires enable_nat_gateway=true."
  type        = bool
  default     = false
}

variable "desired_count" {
  description = "Number of frontend and backend ECS tasks."
  type        = number
  default     = 1
}

variable "log_retention_in_days" {
  description = "CloudWatch log retention for development."
  type        = number
  default     = 7
}

variable "enable_container_insights" {
  description = "Enable ECS Container Insights, which may add CloudWatch costs."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Common tags for future AWS resources."
  type        = map(string)
  default     = {}
}
