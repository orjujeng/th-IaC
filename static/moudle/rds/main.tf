#rds 需要建立一个专属于rds的子网组子网组内会定义需要在哪一个az下建立这个rds实例
resource "aws_db_subnet_group" "application_rds_subnet_group" {
  name       = "${var.perfix}_rds_subnet_group"
  subnet_ids = var.rds_subnet_ids
  tags = {
    Name = "${var.perfix}_rds_subnet_group"
  }
}
#rds sg设置只允许ecs和ec2访问
resource "aws_security_group" "application_rds_sg" {
  name        = "${var.perfix}_rds_sg"
  description = "Allow container to RDS"
  vpc_id      = var.vpc_id

  ingress {
    description     = "container to rds"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = var.container_sg_id
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.perfix}_rds_sg"
  }
}
#rds参数组（更改时区）
resource "aws_db_parameter_group" "application_rds_parameter_group" {
  name        = "${var.perfix}-parameter-group"
  family      = "mysql8.0"
  description = "${var.perfix}-parameter-group"

  parameter {
    name  = "time_zone"
    value = "Asia/Shanghai"
  }
}
#rds 实例符合免费策略
resource "aws_db_instance" "application_mysql_rds" {
  allocated_storage       = 10 
  availability_zone       = var.rds_availability_zone
  backup_retention_period = 7
  db_subnet_group_name    = aws_db_subnet_group.application_rds_subnet_group.name
  parameter_group_name    = aws_db_parameter_group.application_rds_parameter_group.name
  engine                  = "mysql"
  engine_version          = "8.0.35"
  instance_class          = "db.t3.micro"
  username                = "root"
  password                = "root12345678"
  port                    = 3306
  vpc_security_group_ids  = [aws_security_group.application_rds_sg.id]
  multi_az                = false
  skip_final_snapshot     = true
  tags = {
    name : "${var.perfix}_mysql_rds"
  }
}