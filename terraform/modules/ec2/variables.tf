variable "name" { type = string }
variable "vpc_id" { type = string }
variable "subnet_id" { type = string }
variable "instance_type" {
  type    = string
  default = "t3.medium"
}
variable "ami_id" {
  type    = string
  default = ""
}
variable "key_name" { type = string }
variable "associate_public_ip" {
  type    = bool
  default = true
}
variable "volume_size" {
  type    = number
  default = 30
}
variable "user_data" {
  type    = string
  default = ""
}
variable "ingress_rules" {
  type = list(object({
    description = string
    port        = number
    cidr_blocks = list(string)
  }))
  default = []
}
