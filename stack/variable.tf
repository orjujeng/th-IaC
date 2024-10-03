variable "region" {
  type = string
}
variable "start_service" {
  type    = bool
  default = false
}

#花钱服务，不用的时候关闭。建议每天检查一下
variable "shutdown_saving_cost" {
  type    = bool
  default = false
}
variable "ssh_key" {
  type     = string
  nullable = false
}
variable "bastion_status" {
  type    = bool
  default = false
}

variable "mode" {
  type     = string
  nullable = false
}