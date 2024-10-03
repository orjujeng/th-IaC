variable "perfix" {
  type = string
  nullable = false
}

variable "container_status" {
  type = bool
  nullable = false
}

variable "ssh_key" {
  type = string
  nullable = false
}

variable "bastion_status" {
  type = bool
  nullable = false
}