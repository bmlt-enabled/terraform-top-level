resource "aws_lb" "bmlt" {
  name            = "bmlt"
  subnets         = [aws_subnet.public_a.id, aws_subnet.public_b.id]
  security_groups = [aws_security_group.http_load_balancer.id]

  access_logs {
    bucket  = aws_s3_bucket.bmlt_alb_logs.bucket
    enabled = true
  }

  tags = {
    Name = "bmlt"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.bmlt.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.bmlt.id
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = data.aws_acm_certificate.bmltenabled_org.arn
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "BMLT"
      status_code  = "200"
    }
  }
}
