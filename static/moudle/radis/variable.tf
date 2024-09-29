variable "perfix" {
  type = string
  nullable = false
}

variable "redis_subnet_ids" {
   type = list
   nullable = false
}
variable "cluster_mode" {
  type = bool
  nullable = false
}
variable "container_sg_id" {
  type = list
  nullable = false
}
variable "vpc_id" {
  type = string
  nullable = false
}