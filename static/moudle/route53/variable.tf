variable "domain_name" {
  type = string
  nullable = false
}
variable "perfix" {
  type = string
  nullable = false
}

variable "rds_address" {
  type = string
}

variable "redis_address" {
  type = list
}

variable "fe_domain_name" {
  type = string
}