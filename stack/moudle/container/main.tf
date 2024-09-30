#新的给container使用的iam role，其中assume 是指给aws那个服务/人使用
resource "aws_iam_role" "application_container_iam_role" {
  name               = "${var.perfix}_ec2_iam_role"
  assume_role_policy = data.aws_iam_policy_document.container_assume_role.json
}

#role和policy的结合 role可以被aws service使用，policy是使用的范围 (session manager 访问权限)
resource "aws_iam_role_policy_attachment" "container_iam_role_attach_ssm" {
  role       = aws_iam_role.application_container_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
}

#当这个role需要给ec2相关的contain使用时，必须添加instance profile，并且删的时候需要通过cli命令进行删除。
resource "aws_iam_instance_profile" "application_container_instance_profile" {
  name = "${var.perfix}_ec2_instance_profile"
  role = aws_iam_role.application_container_iam_role.name
}

#ec2 
resource "aws_instance" "application_container_bastion_instance" {
  count                       = var.container_status ? 1:0
  ami                         = data.aws_ami.latest-ecs-support-ami.id
  instance_type               = "t2.micro"
  subnet_id                   = data.aws_subnets.inside_subnets.ids[0] #inside 1 子网中建立
  vpc_security_group_ids      = [data.aws_security_group.application_container_sg.id]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.application_container_instance_profile.name
  user_data = <<EOF
                 #!/bin/bash
                 sudo yum install -y docker wget
                 sudo systemctl start docker
                 sudo usermod -aG docker ec2-user
                 sudo CODEDEPLOY_BIN="/opt/codedeploy-agent/bin/codedeploy-agent"
                 sudo $CODEDEPLOY_BIN stop
                 sudo yum erase codedeploy-agent -y
                 sudo yum install ruby -y 
                 sudo cd /home/ec2-user 
                 sudo wget https://aws-codedeploy-ap-northeast-1.s3.ap-northeast-1.amazonaws.com/latest/install
                 sudo chmod +x ./install
                 sudo ./install auto
              EOF
  tags = {
    Name = "${var.perfix}_container_bastion_instance"
  }
}