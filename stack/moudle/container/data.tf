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
# 给ploicy赋role
data "aws_iam_policy_document" "container_assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}
#获取inside子网id
data "aws_subnets" "inside_subnets" {
filter {
    name   = "tag:Name"
    values = ["th-dev_inside_subnet*"]
  }
}
#获取contain sg的
data "aws_security_group" "application_container_sg" {
  filter {
    name   = "group-name"  
    values = ["${var.perfix}_container_sg"]
  }
}
