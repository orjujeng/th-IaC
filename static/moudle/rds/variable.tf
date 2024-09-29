variable "perfix" {
  type = string
  nullable = false
}

variable "rds_subnet_ids"{
    type = list
    nullable = false
}

variable "rds_availability_zone"{
    type = string
    nullable = false
}

variable "vpc_id"{
    type = string
    nullable = false
}

variable "container_sg_id"{
    type = list
    nullable = false
}