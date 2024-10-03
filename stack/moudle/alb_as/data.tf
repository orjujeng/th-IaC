data "aws_subnets" "inside_subnets" {
filter {
    name   = "tag:Name"
    values = ["th-dev_inside_subnet*"]
  }
}

data "aws_vpc" "application_vpc" {
  filter {
    name   = "tag:Name"
    values = ["th-dev_vpc"]  
  }
}

#获取contain sg的
data "aws_security_group" "application_container_sg" {
  filter {
    name   = "group-name"  
    values = ["${var.perfix}_container_sg"]
  }
}

data "aws_iam_instance_profile" "application_container_instance_profile" {
  name = "${var.perfix}_ec2_instance_profile"
}

#获取最新基于ecs优化的ec2实例id
data "aws_ami" "latest-ecs-support-ami" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*-x86_64-ebs"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}