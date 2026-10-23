variable "repositories" {
  description = "ECR repositories to create, keyed by logical service name."
  type = map(object({
    name = string
  }))
}

variable "image_retention_count" {
  description = "Number of images retained per repository."
  type        = number
  default     = 10
}

variable "tags" {
  description = "Tags applied to ECR resources."
  type        = map(string)
  default     = {}
}
