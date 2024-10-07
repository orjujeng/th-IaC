#s3私有桶也能让cf访问的oai，需要在s3中添加策略
resource "aws_cloudfront_origin_access_identity" "application_fe_oai" {
  comment = "OAI for accessing FE S3 bucket"
}
resource "aws_s3_bucket_policy" "application_fes3_attch_oai" {
  bucket = data.aws_s3_bucket.application_fe_s3.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = aws_cloudfront_origin_access_identity.application_fe_oai.iam_arn
        }
        Action   = "s3:GetObject"
        Resource = "${data.aws_s3_bucket.application_fe_s3.arn}/*"
      }
    ]
  })
}
# 创建 CloudFront 分配
resource "aws_cloudfront_distribution" "application_distribution" {
  count =var.shutdown_saving_cost?1:0
  price_class = "PriceClass_100" #最便宜模式
  web_acl_id  = null             #禁止waf           
  origin {
    domain_name = data.aws_s3_bucket.application_fe_s3.bucket_regional_domain_name
    origin_id   = "FES3"
    # 允许 OAI 访问
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.application_fe_oai.cloudfront_access_identity_path
    }
  }
  origin {
    domain_name = "${var.aws_api_gateway_URL}.execute-api.ap-northeast-1.amazonaws.com" # API Gateway 的域名
    origin_id   = "APIGateway"
    origin_path = "/dev"
    custom_origin_config {
    http_port                = 80
    https_port               = 443
    origin_keepalive_timeout = 5
    origin_protocol_policy   = "https-only"
    origin_read_timeout      = 30
    origin_ssl_protocols = [
      "TLSv1.2",
    ]
  }
  }
  ordered_cache_behavior {
    path_pattern           = "/api/*" # 只匹配以 /api 开头的请求
    target_origin_id       = "APIGateway"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods         = ["GET", "HEAD"]
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 86400
    compress    = true
  }
  enabled             = true
  default_root_object = "index.html" # 替换为你的默认根对象 否则不会跳转到主页

  # 提供备用域名
  aliases = ["${var.fe_domain_name}"] # 替换为你的备用域名
  default_cache_behavior {
    target_origin_id       = "FES3"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD"] #会缓存的方法  
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 86400
    compress    = true
  }


  # SSL 配置
  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.application_certificate[0].arn # 替换为你的 ACM 证书 ARN
    ssl_support_method  = "sni-only"
  }
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  tags = {
    Name = "${var.perfix}-cloudfront"
  }
}


