#route 53在创建时默认携带两个dns相关的record 不需要额外创建 但是ns必须是domian系统指定的ns域名，切记别忘更改
#如果record建立，相应的dns查询就会计费不算便宜建议删掉record在不用的时候。
resource "aws_route53_zone" "application_route53_zone" {
  name  = var.domain_name
}

#rds cname record 
resource "aws_route53_record" "application_rds_cname" {
  name    = "${var.perfix}-rds"
  type    = "CNAME"
  zone_id = aws_route53_zone.application_route53_zone.id
  ttl     = 300
  records = [var.rds_address] 
}
#redis cname record 
resource "aws_route53_record" "application_redis_cname" {
  name    = "${var.perfix}-redis"
  type    = "CNAME"
  zone_id = aws_route53_zone.application_route53_zone.id
  ttl     = 300
  records = var.redis_address
}



