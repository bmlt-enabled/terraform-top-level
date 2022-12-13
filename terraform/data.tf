data "aws_elb_service_account" "main" {}

data "aws_acm_certificate" "bmltenabled_org" {
  domain      = "*.bmltenabled.org"
  statuses    = ["ISSUED"]
  most_recent = true
}

data "aws_route53_zone" "aws_bmlt_app" {
  name         = "aws.bmlt.app."
  private_zone = false
}

data "aws_route53_zone" "tomato_bmltenabled_org" {
  name         = "tomato.bmltenabled.org."
  private_zone = false
}

data "aws_route53_zone" "na-bmlt_org" {
  name         = "na-bmlt.org."
  private_zone = false
}

data "aws_secretsmanager_secret" "docker" {
  name = "docker"
}
