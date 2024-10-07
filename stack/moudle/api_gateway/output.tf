output "aws_api_gateway_URL" {
  value = aws_api_gateway_deployment.application_gateway_deployment.rest_api_id
}