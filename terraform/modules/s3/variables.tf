variable "name" {
  type        = string
  description = "Bucket name prefix (a random suffix is appended for uniqueness)"
}
variable "versioning" {
  type    = bool
  default = false
}
variable "expiration_days" {
  type        = number
  default     = 0
  description = "0 = no lifecycle expiration"
}
variable "flow_logs_policy" {
  type        = bool
  default     = false
  description = "Attach the VPC Flow Logs delivery bucket policy"
}
variable "force_destroy" {
  type    = bool
  default = false
}
