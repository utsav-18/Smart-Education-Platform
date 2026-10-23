variable "project_name" {
  description = "Stable project identifier used for future Azure resource names."
  type        = string
  default     = "smart-education-platform"
}

variable "environment" {
  description = "Deployment environment name."
  type        = string
  default     = "dev"
}

variable "azure_location" {
  description = "Azure region for the development environment."
  type        = string
}

variable "azure_subscription_id" {
  description = "Azure subscription ID supplied through local authentication or CI."
  type        = string
  sensitive   = true
}

variable "azure_tenant_id" {
  description = "Azure tenant ID supplied through local authentication or CI."
  type        = string
  sensitive   = true
}

variable "container_images" {
  description = "Future container image references for the frontend and backend."
  type = object({
    frontend = string
    backend  = string
  })
  default = {
    frontend = ""
    backend  = ""
  }
}

variable "tags" {
  description = "Common tags for future Azure resources."
  type        = map(string)
  default     = {}
}
