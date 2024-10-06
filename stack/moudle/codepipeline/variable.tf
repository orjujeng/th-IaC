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

variable "ecr_repo" {
  type=string
}

variable "ecs_cluster_name" {
  type=string
}

variable "ecs_service_name" {
  type=string
}

variable "ecs_alb_listener_arn" {
  type=string
}

variable "ecs_tg_name" {
  type=string
}

variable "ecs_tg_b_name" {
  type=string
}