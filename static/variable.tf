variable "region" {
  type = string
}

variable "start_service" {
  type    = bool
  default = false
}

variable "domain_name" {
   type = string
}
#花钱服务，不用的时候关闭。建议每天检查一下
variable "shutdown_saving_cost" {
  type    = bool
  default = false
}

variable "fe_domain_name" {
  type = string
}