output "state_dynamodb_name" {
  value = aws_dynamodb_table.dynamodb_terraform_lock.name
}