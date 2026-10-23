variable "log_groups" {
  description = "CloudWatch log groups keyed by logical service name."
  type        = map(string)
}

variable "retention_in_days" {
  description = "CloudWatch retention period for development logs."
  type        = number
  default     = 7
}

variable "tags" {
  description = "Tags applied to log groups."
  type        = map(string)
  default     = {}
}
