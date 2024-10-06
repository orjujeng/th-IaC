variable "perfix" {
  type = string
  nullable = false
}
variable "mode" {
  type = string
  nullable = false
}

variable "application_ecs_base_on_ec2_autoscaling_arn" {
   type = string
   nullable = false
}
variable "ecs_task_desired_num" {
  type= number
  nullable = false
}
variable "ecs_target_group_arn" {
  type = string
  nullable = false
}
variable "ecs_task_max_num" {
  type= number
  nullable = false
}
variable "ecs_task_min_num" {
  type= number
  nullable = false
}

variable "shutdown_saving_cost" {
  type= bool
  nullable = false
}