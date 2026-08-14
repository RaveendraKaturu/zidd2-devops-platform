variable "name" {
  type    = string
  default = "zidd2"
}
variable "secrets" {
  type        = map(map(string))
  description = "map of secret-name => {key=value,...}"
  default     = {}
}
variable "recovery_window_in_days" {
  type    = number
  default = 7
}
