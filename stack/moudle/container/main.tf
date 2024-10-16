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
resource "aws_iam_role_policy_attachment" "container_iam_role_attach_s3" {
  role       = aws_iam_role.application_container_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "container_iam_role_attach_ecs" {
  role       = aws_iam_role.application_container_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

#当这个role需要给ec2相关的contain使用时，必须添加instance profile，并且删的时候需要通过cli命令进行删除。
resource "aws_iam_instance_profile" "application_container_instance_profile" {
  name = "${var.perfix}_ec2_instance_profile"
  role = aws_iam_role.application_container_iam_role.name
}

#连接本地ssh连接 ec2的key 获取途径 cat ~/.ssh/id_rsa.pub 本地一定要安装ssh，并且sg开启22号端口
resource "aws_key_pair" "local_macmini_ec2_key_pair" {
  key_name   = "local_macmini_ec2_key_pair"
  public_key = var.ssh_key
  tags = {
    Name = "local_macmini_ec2_key_pair"
  }
}

#ec2  bastion
resource "aws_instance" "application_container_bastion_instance" {
  count                       = var.container_status && var.bastion_status ? 1:0
  ami                         = data.aws_ami.latest-ecs-support-ami.id
  instance_type               = "t2.micro"
  subnet_id                   = data.aws_subnets.inside_subnets.ids[0] #inside 1 子网中建立
  vpc_security_group_ids      = [data.aws_security_group.application_container_sg.id]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.application_container_instance_profile.name
  key_name                    = aws_key_pair.local_macmini_ec2_key_pair.key_name
  user_data = <<EOF
                 #!/bin/bash
                 sudo yum install -y wget mysql
              EOF
  tags = {
    Name = "${var.perfix}_container_bastion_instance"
  }
}