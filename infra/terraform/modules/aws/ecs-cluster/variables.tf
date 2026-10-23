variable "name" {
  description = "ECS cluster name."
  type        = string
}

variable "enable_container_insights" {
  description = "Enable ECS Container Insights. This may add CloudWatch costs."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags applied to the ECS cluster."
  type        = map(string)
  default     = {}
}
