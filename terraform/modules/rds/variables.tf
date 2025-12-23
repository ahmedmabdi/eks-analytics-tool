variable "db_name" {
  description = "The name of the Postgres database to create."
  type        = string
  default     = "umami"
}
variable "vpc_id" {
    type =string
}
variable "instance_type" {
  type = string
}

variable "allocated_storage" {
  type    = number
  default = 20
}

variable "publicly_accessible" {
  type    = bool
  default = true
}

variable "engine_version" {
  type    = string
  default = "15.3"
}
variable "db_identifier" {
  type    = string
  default = "umami-db"
}
variable "project_name" {
  type    = string
}
variable "private_subnets" {
  type = list(string)
}
variable "rds_username" {
  description = "RDS username from SSM"
  type        = string
}

variable "rds_password" {
  description = "RDS password from SSM"
  type        = string
  sensitive   = true
}