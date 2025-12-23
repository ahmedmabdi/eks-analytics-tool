variable "name" {
  type = string
}
variable "repository" {
  type = string
}
variable "chart" {
  type = string
}
variable "chart_version" {
  type = string
  default = null
}
variable "namespace" {
  type = string
}
variable "timeout" {
  type = number
  default = 300
}

variable "values_file" {
  type = string
}