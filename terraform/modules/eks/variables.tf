variable "name" {
  type = string
}
variable "kubernetes_version" {
  type = string
}
variable "vpc_id" {
  type = string
}
variable "private_subnets" {
  type = list(string)
}
variable "public_subnets" {
  type = list(string)
}
variable "endpoint_public_access" {
  type = bool
  default = true
}
variable "endpoint_public_access_cidrs" {
  type = list(string)
  default = [ "0.0.0.0/0" ]
}
variable "eks_managed_node_groups" {
  type = any
}
variable "tags" {
  type = map(string)
}