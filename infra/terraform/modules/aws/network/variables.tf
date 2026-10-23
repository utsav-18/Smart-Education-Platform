variable "name" {
  description = "Network name prefix."
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block."
  type        = string
}

variable "availability_zones" {
  description = "Availability zones. Empty selects the first two available zones."
  type        = list(string)
  default     = []
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDRs, one per selected availability zone."
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDRs, one per selected availability zone."
  type        = list(string)
}

variable "enable_nat_gateway" {
  description = "Create one NAT gateway for private subnet egress. NAT gateways add hourly and data-processing costs."
  type        = bool
  default     = false
}

variable "service_ports" {
  description = "Ports permitted from the ALB security group to ECS services."
  type        = set(number)
  default     = [80, 5000]
}

variable "tags" {
  description = "Tags applied to networking resources."
  type        = map(string)
  default     = {}
}
