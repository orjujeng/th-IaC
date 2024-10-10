resource "aws_acm_certificate" "application_certificate" {
  count =var.shutdown_saving_cost?1:0
  provider        = aws.east
  domain_name       = "*.${var.domain_name}"
  validation_method = "DNS"

  tags = {
    Name = "${var.domain_name} certificate"
  }
}
#为了验证域名的record在你名下能建立的新record 验证完可以删除
resource "aws_route53_record" "application_certificate_valid_record" {

  zone_id  = data.aws_route53_zone.application_route53_zone_id.zone_id
  for_each = {
    for dvo in aws_acm_certificate.application_certificate[0].domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
  ttl      = 60
  name            = each.value.name
  records         = [each.value.record]
  type            = each.value.type
}

# resource "aws_acm_certificate_validation" "application_certificate_valid" {
#   count =var.shutdown_saving_cost?1:0
#   certificate_arn         = aws_acm_certificate.application_certificate[0].arn
#   validation_record_fqdns = [for record in aws_route53_record.application_certificate_valid_record : record.fqdn]
# }


resource "aws_route53_record" "application_cloudfront_alias_record" {
  count =var.shutdown_saving_cost?1:0
  zone_id = data.aws_route53_zone.application_route53_zone_id.zone_id
  name    = var.fe_domain_name                  # 替换为你希望的子域名
  type    = "A"
  alias {
    name                   = aws_cloudfront_distribution.application_distribution[0].domain_name
    zone_id                = "Z2FDTNDATAQYW2"  # CloudFront 的区域 ID
    evaluate_target_health = false
  }
}