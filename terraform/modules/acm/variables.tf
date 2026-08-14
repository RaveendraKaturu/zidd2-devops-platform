variable "domain_name" { type = string }
variable "subject_alternative_names" {
  type    = list(string)
  default = []
}
variable "wait_for_validation" {
  type        = bool
  default     = true
  description = "Block until the DNS records validate (they must exist first)"
}
