variable "perfix" {
  type = string
  nullable = false
}

variable "frontend_repo" {
  type = string
  nullable = false
}

variable "frontend_branch" {
  type = string
  nullable = false
}
variable "shutdown_saving_cost" {
  type = bool
  nullable = false
}