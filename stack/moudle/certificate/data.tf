resource "aws_acm_certificate" "example_cert" {
  domain_name       = "*.orjujeng.click"  # 替换为你自己的域名
  validation_method = "DNS"
  # ACM 将生成一个需要 DNS 记录的 ARN 列表
  lifecycle {
    create_before_destroy = true
  }
}

# 创建 DNS 验证记录
resource "aws_route53_record" "cert_validation" {
  count   = length(aws_acm_certificate.example_cert.domain_validation_options)
  zone_id = data.aws_route53_zone.my_zone.zone_id
  name    = aws_acm_certificate.example_cert.domain_validation_options[count.index].resource_record_name
  type    = aws_acm_certificate.example_cert.domain_validation_options[count.index].resource_record_type
  ttl     = 60
  records = [aws_acm_certificate.example_cert.domain_validation_options[count.index].resource_record_value]
}

# 验证证书：等待 DNS 验证通过
resource "aws_acm_certificate_validation" "example_cert_validation" {
  certificate_arn         = aws_acm_certificate.example_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}