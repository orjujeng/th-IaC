#不同模式的alb（ec2 mode 和 ecs mode）

#ec2 模式的整套操作：
   #1 新建立一个负载均衡器
   #2 建立tg指向这个负载均衡器
   #3 autoscaling 根据template将ec2关联到tg中，和alb连接
resource "aws_security_group" "applicaton_load_balance_sg" {
  name        = "${var.perfix}_load_balance_sg"
  description = "Allow Http Https traffic"
  vpc_id      = data.aws_vpc.application_vpc.id
  #应该只放行api gateway 等我完善一下
  ingress {
    description = "http resoucre to alb"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    prefix_list_ids = []
  }
  tags = {
    Name = "${var.perfix}_load_balance_sg"
  }
}


resource "aws_alb" "applicaton_load_balance" {
  count = var.shutdown_saving_cost ? 1:0
  name               = "${var.perfix}-${var.mode}-load-balance"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.applicaton_load_balance_sg.id]
  subnets            = data.aws_subnets.inside_subnets.ids
  enable_deletion_protection = false
  tags = {
    Name = "${var.perfix}-${var.mode}-load-balance"
  }
}

#ec2 的 target_group 实例的8080端口暴露给alb
resource "aws_lb_target_group" "applicaton_target_group" {
  count        = var.mode=="ecc" ? 1 : 0 
  name        = "${var.perfix}-${var.mode}-target-group"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.application_vpc.id
  target_type = "instance"
  tags = {
    Name = "${var.perfix}-${var.mode}-target-group"
  }
  health_check {
    path                = "/actuator/health"
    interval            = 300
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

#ec2 的 target_group 与alb 关联 其中alb的80端口指向 实例的8080端口
resource "aws_lb_listener" "applicaton_lb_ass_target" {
  count             = var.mode=="ecc" && var.shutdown_saving_cost? 1 : 0 
  load_balancer_arn = aws_alb.applicaton_load_balance[0].arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.applicaton_target_group[0].arn
  }
}

#ec2 的启动 template
resource "aws_launch_template" "applicaton_ec2_template" {
  name = "${var.perfix}-${var.mode}-ec2-template"
  iam_instance_profile {
    name = data.aws_iam_instance_profile.application_container_instance_profile.name
  }
  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [data.aws_security_group.application_container_sg.id]
  }
  image_id = data.aws_ami.latest-ecs-support-ami.id
  instance_initiated_shutdown_behavior = "terminate"

  instance_type = "t2.micro"

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.perfix}-${var.mode}-ec2"
    }
  }
  tags = {
    Name = "${var.perfix}-${var.mode}-ec2-template"
  }
  user_data = var.mode =="ecc"? filebase64("./moudle/alb_as/buildspec/ec2_init.sh") : filebase64("./moudle/alb_as/buildspec/ecs_init.sh")
}
#ec2 的acto_scaling
resource "aws_autoscaling_group" "applcition_ec2_autoscaling" {
  count             = var.mode=="ecc" ? 1 : 0 
  name                      = "${var.perfix}-${var.mode}-autoscaling"
  max_size                  = var.max_size
  min_size                  = var.min_size
  desired_capacity          = var.expect_size
  health_check_grace_period = 300
  health_check_type         = "ELB" ##ELB//EC2
  force_delete              = true
  vpc_zone_identifier       = data.aws_subnets.inside_subnets.ids

  launch_template {
    name    = aws_launch_template.applicaton_ec2_template.name
    version = "$Latest"
  }
  target_group_arns = [aws_lb_target_group.applicaton_target_group[0].arn]
  tag {
    key                 = "Name"
    value               = "${var.perfix}-${var.mode}-ec2-template"
    propagate_at_launch = true
  }
}