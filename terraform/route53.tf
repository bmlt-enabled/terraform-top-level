resource "aws_route53_zone" "aws_bmlt_app" {
  name = "aws.bmlt.app"
  tags = { Name = "aws.bmlt.app" }
}

resource "aws_route53_zone" "na-bmlt_org" {
  name = "na-bmlt.org"
  tags = { Name = "na-bmlt.org" }
}

resource "aws_route53_record" "bmltenabled" {
  zone_id = data.aws_route53_zone.aws_bmlt_app.id
  name    = "lb.${aws_route53_zone.aws_bmlt_app.name}"
  type    = "A"

  alias {
    name                   = aws_lb.bmlt.dns_name
    zone_id                = aws_lb.bmlt.zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "bmlt_validation" {
  for_each = {
    for dvo in aws_acm_certificate.bmlt.domain_validation_options : dvo.domain_name => {
      name    = dvo.resource_record_name
      record  = dvo.resource_record_value
      type    = dvo.resource_record_type
      zone_id = dvo.domain_name == "tomato.bmltenabled.org" ? data.aws_route53_zone.tomato_bmltenabled_org.zone_id : dvo.domain_name == "tomato.na-bmlt.org" ? data.aws_route53_zone.na-bmlt_org.zone_id : data.aws_route53_zone.aws_bmlt_app.zone_id
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = each.value.zone_id
}
