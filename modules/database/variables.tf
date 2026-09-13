variable "environment" { type = string }
variable "vpc_id" { type = string }
variable "private_subnet_ids" { type = list(string) }
variable "multi_az" {
  description = "Enable High Availability (Active/Standby)"
  type        = bool
}