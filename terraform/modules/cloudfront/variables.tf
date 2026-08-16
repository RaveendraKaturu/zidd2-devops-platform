variable "name" { type = string }
variable "domain_name" { type = string }
variable "origin_domain_name" {
  type        = string
  description = "ALB DNS name to use as the origin"
}
variable "certificate_arn" {
  type        = string
  description = "us-east-1 ACM cert ARN"
}
variable "rate_limit" {
  type    = number
  default = 100
}
