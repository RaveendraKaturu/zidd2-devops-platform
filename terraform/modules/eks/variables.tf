variable "name" {
  type = string
}
variable "k8s_version" {
  type    = string
  default = "1.30"
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
variable "node_desired_size" {
  type    = number
  default = 3
}
variable "node_min_size" {
  type    = number
  default = 2
}
variable "node_max_size" {
  type    = number
  default = 5
}
variable "addon_versions" {
  type = object({
    vpc_cni    = string
    coredns    = string
    kube_proxy = string
    ebs_csi    = string
  })
  # Look up compatible versions for your k8s_version with:
  #   aws eks describe-addon-versions --addon-name vpc-cni --kubernetes-version 1.30
  default = {
    vpc_cni    = "v1.18.3-eksbuild.2"
    coredns    = "v1.11.1-eksbuild.9"
    kube_proxy = "v1.30.3-eksbuild.5"
    ebs_csi    = "v1.33.0-eksbuild.1"
  }
}
