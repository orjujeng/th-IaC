#!/bin/bash
#安装docker并将ec2-user添加进docker组
sudo -i
yum install -y docker wget
yum install mysql -y
systemctl start docker
usermod -aG docker ec2-user
#停止codedeploy-agent 并删除
CODEDEPLOY_BIN="/opt/codedeploy-agent/bin/codedeploy-agent"
$CODEDEPLOY_BIN stop
yum erase codedeploy-agent -y
#重新下载codedeploy-agent
yum install ruby -y 
cd /home/ec2-user 
wget https://aws-codedeploy-ap-northeast-1.s3.ap-northeast-1.amazonaws.com/latest/install
chmod +x ./install
./install auto