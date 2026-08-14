variable "name" { type = string }
variable "github_org" { type = string }
variable "github_repo" { type = string }
variable "ecr_repository_arns" {
  type    = list(string)
  default = []
}
variable "create_oidc_provider" {
  type        = bool
  default     = true
  description = "false if the GitHub OIDC provider already exists in the account"
}
variable "existing_oidc_provider_arn" {
  type    = string
  default = ""
}
