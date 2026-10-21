resource "aws_cloudfront_vpc_origin" "gateway" {
  vpc_origin_endpoint_config {
    name                   = "${var.project_name}-gateway-origin"
    arn                    = var.gateway_nlb_arn
    http_port              = 80
    https_port             = 443
    origin_protocol_policy = "http-only"

    origin_ssl_protocols {
      items    = ["TLSv1.2"]
      quantity = 1
    }
  }
}

resource "aws_cloudfront_distribution" "main" {
  enabled = true
  aliases = var.aliases
  comment = "${var.project_name} CloudFront"

  origin {
    domain_name = var.gateway_nlb_dns_name
    origin_id   = "gateway-vpc-origin"

    vpc_origin_config {
      vpc_origin_id = aws_cloudfront_vpc_origin.gateway.id
    }
  }

  default_cache_behavior {
    target_origin_id       = "gateway-vpc-origin"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = [
      "GET",
      "HEAD",
      "OPTIONS",
      "PUT",
      "POST",
      "PATCH",
      "DELETE"
    ]

    cached_methods = [
      "GET",
      "HEAD"
    ]

    forwarded_values {
      query_string = true

      cookies {
        forward = "all"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = var.acm_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
}