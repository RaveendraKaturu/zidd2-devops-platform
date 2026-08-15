variable "name" {
  type = string
}
variable "k8s_version" {
  type    = string
  default = "1.31"
}
variable "private_subnet_ids" {
  type = list(string)
}
variable "public_subnet_ids" {
  type = list(string)
}
variable "public_access_cidrs" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
  description = "CIDRs allowed to reach the public API endpoint. Lock down in prod."
}
variable "node_instance_types" {
  type    = list(string)
  default = ["t3.large"]
}
variable "node_ami_type" {
  type        = string
  default     = "AL2023_x86_64_STANDARD"
  description = "EKS-optimized AMI family for the node group"
}
variable "node_desired_size" {
  type    = number
  default = 2
}
variable "node_min_size" {
  type    = number
  default = 2
}
variable "node_max_size" {
  type    = number
  default = 5
}

variable "alb_security_group_id" {
  description = "Security group ID of the Application Load Balancer"
  type        = string
}

