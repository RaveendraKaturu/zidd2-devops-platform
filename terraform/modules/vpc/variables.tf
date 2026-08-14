variable "name" {
  type        = string
  description = "Name prefix for VPC resources"
}

variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "CIDR block for the VPC"
}

variable "single_nat_gateway" {
  type        = bool
  default     = true
  description = "true = 1 NAT (cheap), false = 1 NAT per AZ (HA)"
}

variable "flow_logs_bucket_arn" {
  type        = string
  description = "ARN of the S3 bucket for VPC flow logs (from bootstrap)"
}
