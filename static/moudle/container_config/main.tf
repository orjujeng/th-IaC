#ecs和ec2共用的sg
resource "aws_security_group" "application_container_sg" {
  name        = "${var.perfix}_container_sg"
  description = "Allow SSH Http Https traffic"
  vpc_id      = var.vpc_id
  ingress {
    description = "SSH connect container"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description     = "ecc alb to ec2"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [data.aws_security_group.application_alb_sg.id]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    prefix_list_ids = []
  }

  tags = {
    Name = "${var.perfix}_container_sg"
  }
}