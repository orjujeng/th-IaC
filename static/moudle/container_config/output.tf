output "container_sg_id" {
  value = [aws_security_group.application_container_sg.id]
}