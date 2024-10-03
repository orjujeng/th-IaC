output "applcition_ec2_autoscaling_id" {
  value = aws_autoscaling_group.applcition_ec2_autoscaling[0].id
}

output "applcition_applicaton_load_balance_name" {
  value = aws_alb.applicaton_load_balance.name
}