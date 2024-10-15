# # Cloudfront and acm cert with r53 record
resource "aws_cloudfront_distribution" "alb_distribution" {
  origin {
    domain_name = aws_lb.gearpal_alb.dns_name
    origin_id   = aws_lb.gearpal_alb.id
    custom_origin_config {
            http_port                 = 80
            https_port                = 443
            origin_protocol_policy    = "match-viewer"
            origin_ssl_protocols      = ["TLSv1.2"]
        }
        custom_header {
        name  = "ENV"
        value = var.env_cloudfront_header
      }
  }

  enabled             = true
  #is_ipv6_enabled     = true
  comment             = "CloudFront distribution for ${var.environment} environment using LoadBalancer"
  aliases             = [ trim(lookup(var.custom_domain,var.environment), ".") ]

  logging_config {
    include_cookies = false
    bucket          = "eai-cloudfrontlogs-${var.environment}.s3.amazonaws.com"
    prefix          = var.prefix_cdn_distribution
  }

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_lb.gearpal_alb.id
    cache_policy_id  = var.cache_policy_id
    viewer_protocol_policy = var.viewer_protocol_policy
    min_ttl                = var.min_ttl
    default_ttl            = var.default_ttl
    max_ttl                = var.max_ttl
    origin_request_policy_id   = var.origin_request_policy_id
    response_headers_policy_id = var.response_headers_policy_id
    # lambda_function_association {
    #   event_type   = "origin-request"
    #   include_body = true
    #   lambda_arn   = var.lambda_edge_function_arn
    # }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = merge({ Name = "eai-gearpal-lb-cf"}, var.tags)

  viewer_certificate {
    acm_certificate_arn             = aws_acm_certificate.eai_gearpal_alb_acm_cert.arn
    cloudfront_default_certificate  = false
    minimum_protocol_version        = "TLSv1.2_2021"
    ssl_support_method              = "sni-only"
  }
  

 web_acl_id = aws_wafv2_web_acl.web_acl_cdn.arn

}

resource "aws_route53_record" "cf_r53_alias" {
  zone_id = lookup(var.zone_id, var.environment)
  name    = lookup(var.custom_domain, var.environment)
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.alb_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.alb_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}


# Enable CloudWatch Real Time monitoring - needed for Datadog latency SLO
resource "aws_cloudfront_monitoring_subscription" "cloudfront_additional_metrics" {

  distribution_id = aws_cloudfront_distribution.alb_distribution.id

  monitoring_subscription {
    realtime_metrics_subscription_config {
      realtime_metrics_subscription_status = "Enabled"
    }
  }
}

