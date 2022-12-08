resource "aws_route53_zone" "aws_bmlt_app" {
  name = "aws.bmlt.app"
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
