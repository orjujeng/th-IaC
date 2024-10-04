variable "perfix" {
  type=string
}
variable "backend_repo" {
  type=string
}
variable "backend_ecc_branch" {
  type=string
}
variable "mode" {
  type=string
  nullable = false
}
variable "ecc_target_group_name" {
  type=string
}
variable "ecc_autoscaling_group_id" {
  type=string
}

variable "shutdown_saving_cost" {
  type = bool
}