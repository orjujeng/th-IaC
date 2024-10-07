data "aws_s3_bucket" "application_fe_s3" {
  bucket = "${var.perfix}-frontend-orjujeng"
}
data "aws_route53_zone" "application_route53_zone_id" {
  name         = var.domain_name
}