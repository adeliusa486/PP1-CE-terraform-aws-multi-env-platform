variable "environment" {
  description = "The name of the environment (dev, staging, prod)"
  type        = string
}

variable "vpc_cidr" {
  description = "The IP address range for the VPC"
  type        = string
}

variable "azs" {
  description = "List of Availability Zones to use"
  type        = list(string)
}

variable "public_subnets" {
  description = "List of public subnet CIDR blocks"
  type        = list(string)
}

variable "private_subnets" {
  description = "List of private subnet CIDR blocks"
  type        = list(string)
}

variable "single_nat_gateway" {
  description = "If true, routes all private subnets through one NAT Gateway to save costs"
  type        = bool
  default     = false
}