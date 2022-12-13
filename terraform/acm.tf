resource "aws_acm_certificate" "bmlt" {
  domain_name = "*.aws.bmlt.app"
  subject_alternative_names = [
    "tomato.bmltenabled.org",
    "tomato.na-bmlt.org"
  ]
  validation_method = "DNS"

  tags = { Name = "BMLT Wildcard" }
}

resource "aws_acm_certificate_validation" "bmlt" {
  certificate_arn         = aws_acm_certificate.bmlt.arn
  validation_record_fqdns = [for record in aws_route53_record.bmlt_validation : record.fqdn]
}
