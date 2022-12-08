resource "aws_s3_bucket" "bmlt_alb_logs" {
  bucket_prefix = "bmlt-logs-"
}

resource "aws_s3_bucket_policy" "bmlt_alb_logs" {
  bucket = aws_s3_bucket.bmlt_alb_logs.id

  policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = [
        {
          Action   = "s3:PutObject"
          Effect   = "Allow"
          Resource = "${aws_s3_bucket.bmlt_alb_logs.arn}/*"
          Principal = {
            AWS = data.aws_elb_service_account.main.arn
          }
        }
      ]
  })
}
