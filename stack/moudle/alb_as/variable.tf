variable "perfix" {
  type = string
  nullable = false
}
variable "mode" {
  type = string
  nullable = false
}

variable "max_size" {
  type = number
  nullable = false
}


variable "min_size" {
  type = number
  nullable = false
}

variable "expect_size" {
  type = number
  nullable = false
}

variable "shutdown_saving_cost"{
  type = bool
  nullable = false
}