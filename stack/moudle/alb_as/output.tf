output "applcition_ec2_autoscaling_id" {
  value = var.mode== "ecc"? aws_autoscaling_group.applcition_ec2_autoscaling[0].id : null
}

output "applcition_load_balance_name" {
  value = var.shutdown_saving_cost?aws_alb.applicaton_load_balance[0].name:null
}

output "applcition_load_balance_dns_name" {
  value = var.shutdown_saving_cost?aws_alb.applicaton_load_balance[0].dns_name:null
}

output "application_ecs_base_on_ec2_autoscaling_arn" {
 value = aws_autoscaling_group.application_ecs_base_on_ec2_autoscaling[0].arn
}

output "ecs_target_group_arn" {
  value = aws_lb_target_group.application_specific_api_target_group[0].arn
}

output "ecs_alb_listener_arn" {
  value =  length(aws_alb_listener.apllcation_alb_ecs_listener) == 0 ? "" : aws_alb_listener.apllcation_alb_ecs_listener[0].arn 
}

output "ecs_tg_name" {
  value = aws_lb_target_group.application_specific_api_target_group[0].name
}

output "ecs_tg_b_name" {
  value = aws_lb_target_group.application_specific_api_target_group_b[0].name
}