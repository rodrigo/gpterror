data "aws_acm_certificate" "cert" {
  domain = "www.gpterror.online"
}

data "aws_s3_bucket" "this" {
  bucket = "rebelatto"
}

locals {
  api_path = split("//", aws_apigatewayv2_api.this.api_endpoint)[1]
  s3_path = data.aws_s3_bucket.this.bucket_domain_name
}

resource "aws_cloudfront_distribution" "this" {
  enabled             = true
  is_ipv6_enabled     = true

  aliases = ["www.gpterror.online"]
  viewer_certificate {
    acm_certificate_arn = data.aws_acm_certificate.cert.arn
    ssl_support_method = "sni-only"
  }

  price_class = "PriceClass_100"
  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }

  origin {
    domain_name = local.s3_path
    origin_access_control_id = aws_cloudfront_origin_access_control.s3.id
    origin_id = local.s3_path
    origin_path = "/certs"
  }

  origin {
    domain_name = local.api_path
    origin_id = local.api_path
    custom_origin_config {
      http_port              = "80"
      https_port             = "443"
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }

  default_cache_behavior {
    cache_policy_id  = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad" # cache disabled
    allowed_methods  = ["HEAD", "GET"]
    cached_methods = ["HEAD", "GET"]
    target_origin_id = local.s3_path
    viewer_protocol_policy = "allow-all"

  }

  ordered_cache_behavior {
    cache_policy_id  = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad" # cache disabled
    path_pattern     = "/"
    allowed_methods  = ["HEAD", "GET"]
    cached_methods = ["HEAD", "GET"]
    target_origin_id = local.api_path
    viewer_protocol_policy = "redirect-to-https"
  }
}

resource "aws_cloudfront_origin_access_control" "s3" {
  name                              = "default s3 access"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}
