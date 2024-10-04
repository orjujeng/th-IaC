#api gateway 的功能来说，作为网关，进行不同请求的不同映射（对于lambda来说）。当然我们也有可替代的alb rule去配置。apigateway只能通过http绑定外部alb，其余都需要通过vpc link绑定（nlb vpc的其他资源）
#分为以下几个部分：
   #创建 API Gateway 
   # 创建 API Gateway 资源 作为跟路径可以指定一些其他路径包括（/web/api）什么的
   # 创建 API Gateway 方法 就是安排这路径下的什么请求（get put delete etc.）
   # 创建集成 就是这个方法会到会到哪一个资源中
   # 需要注意的是 {proxy+}作为资源就是模糊匹配
   # 而alb的结尾的/{proxy}就对应属于 apigateway link + {proxy}的结尾参数 是一种模糊匹配，正常匹配的话需要添加具体资源
#   request_parameters = {
#     "integration.request.path.proxy" = "method.request.path.proxy"
#   } 这个参数就是决定模糊匹配是否展开的，比较重要 他在集成中
# 创建 API Gateway
resource "aws_api_gateway_rest_api" "application_rest_api_gateway" {
  name        = "${var.perfix}-api-gateway"
  description = "API Gateway for application"
}

# 创建 API Gateway 资源
resource "aws_api_gateway_resource" "application_resource" {
  rest_api_id = aws_api_gateway_rest_api.application_rest_api_gateway.id
  parent_id   = aws_api_gateway_rest_api.application_rest_api_gateway.root_resource_id
  path_part   = "{proxy+}"
}

# 创建 API Gateway 方法
resource "aws_api_gateway_method" "application_method" {
  rest_api_id   = aws_api_gateway_rest_api.application_rest_api_gateway.id
  resource_id   = aws_api_gateway_resource.application_resource.id
  http_method   = "ANY"
  authorization = "NONE"
  request_parameters = {
    "method.request.path.proxy" = true
  } 
  
}

# 创建集成
resource "aws_api_gateway_integration" "application_integration" {
  rest_api_id = aws_api_gateway_rest_api.application_rest_api_gateway.id
  resource_id = aws_api_gateway_resource.application_resource.id
  http_method = aws_api_gateway_method.application_method.http_method
  integration_http_method = "ANY"
  type                    = "HTTP_PROXY"
  uri                     = "http://${var.applcition_load_balance_dns_name}/{proxy}" # 内部 ALB 的 DNS 名称
  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  } 
}

# 部署 API Gateway
resource "aws_api_gateway_deployment" "application_gateway_deployment" {
  rest_api_id = aws_api_gateway_rest_api.application_rest_api_gateway.id
  stage_name  = "dev"
  depends_on = [aws_api_gateway_integration.application_integration]
}