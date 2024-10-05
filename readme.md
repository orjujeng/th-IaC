中文文档：
    1st：新建一个除root账号外的 user去拿到aksk并配置 aws congfigure
    2nd: terraform init 
         terraform workspace select th-dev
         terraform plan -var-file="terraform-th-static.tfvars"
         terraform plan -var-file="terraform-th-stack.tfvars"
    3rd：在激活backend s3之前一定要创建dynamo db table 和 s3 bucket
    1. workspace : terraform workspace new "th-dev"
                   terraform workspace select th-dev
                   terraform workspace delete th-dev
                   terraform workspace list
                   terraform force-unlock -force 39ea2e99-72b0-5a96-2302-b12bffbafed2
    2. plan : terraform plan -var-file="terraform-th-static.tfvars/terraform-th-stack.tfvars"
    3. terraform destory 去删除所有由hcl管理的iac
    4. rds url: https://docs.aws.amazon.com/zh_cn/AmazonRDS/latest/UserGuide/CHAP_GettingStarted.CreatingConnecting.MySQL.html#CHAP_GettingStarted.Connecting.MySQL
    连接 mysql -h th-dev-rds.orjujeng.click -P 3306 -u root -p
    5. 堡垒机连接 redis
                     sudo yum install gcc wget -y
                     sudo wget http://download.redis.io/redis-stable.tar.gz
                     sudo tar -xzvf redis-stable.tar.gz
                     cd redis-stable
                     sudo make
                     sudo cp src/redis-cli /usr/bin
                     redis-cli -h th-dev-elasticache.4ublli.0001.apne1.cache.amazonaws.com:6379 -p 6379 -a password
     6. ec2 的每个ipv4地址会收费，0.005刀每小时，不用时ec2关停。 每一个hostzone每月会收取0.5刀的费用建议关停
     7. 本地ide通过ec2连接rds
          ssh -L 3307:th-dev-rds.orjujeng.click:3306 ec2-user@43.207.191.104

 to do：
   tf: s3 关联到cloudfront
       证书 
       api gateway加路径
       cf 配置到apigateway