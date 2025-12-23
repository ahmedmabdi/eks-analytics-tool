variable "name" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "namespace" {
  type = string
}

variable "service_account" {
  type = string
}

variable "attach_cert_manager_policy" {
  type    = bool
  default = true
}

variable "cert_manager_hosted_zone_arns" {
  type    = list(string)
  default = []
}

variable "tags" {
  type = map(string)
}

