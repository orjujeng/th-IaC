中文文档：
    1st：新建一个除root账号外的 user去拿到aksk并配置 aws congfigure
    2nd: terraform init 
         terraform workspace select th-dev
         terraform plan -var-file="terraform-th-static.tfvars/terraform-th-stack.tfvars"
    3rd：在激活backend s3之前一定要创建dynamo db table 和 s3 bucket
    1. workspace : terraform workspace new "th-dev"
                   terraform workspace select th-dev
                   terraform workspace delete th-dev
                   terraform workspace list
    2. plan : terraform plan -var-file="terraform-th-static.tfvars/terraform-th-stack.tfvars"
    3. terraform destory 去删除所有由hcl管理的iac