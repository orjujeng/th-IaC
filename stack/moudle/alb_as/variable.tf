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
variable "ecs_base_on_ec2_max_size" {
  type = number
  nullable = false
}
variable "ecs_base_on_ec2_min_size" {
  type = number
  nullable = false
}
variable "ecs_base_on_ec2_desired_capacity" {
  type = number
  nullable = false
}

variable "ecs_cluster_name" {
  type = string
  nullable = false
}