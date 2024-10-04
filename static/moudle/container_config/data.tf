data "aws_security_group" "application_alb_sg" {
  filter {
    name   = "group-name"  
    values = ["${var.perfix}_load_balance_sg"]
  }
}