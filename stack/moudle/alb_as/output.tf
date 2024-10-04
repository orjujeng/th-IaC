output "applcition_ec2_autoscaling_id" {
  value = aws_autoscaling_group.applcition_ec2_autoscaling[0].id
}

output "applcition_load_balance_name" {
  value = var.shutdown_saving_cost?aws_alb.applicaton_load_balance[0].name:null
}

output "applcition_load_balance_dns_name" {
  value = var.shutdown_saving_cost?aws_alb.applicaton_load_balance[0].dns_name:null
}