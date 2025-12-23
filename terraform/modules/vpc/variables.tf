variable "name" {
  type = string
}
variable "cidr" {
    type = string
}
variable "private_subnets" {
    type = list(string)
}
variable "public_subnets" {
    type = list(string)
}
variable "azs" {
    type = list(string)
}
