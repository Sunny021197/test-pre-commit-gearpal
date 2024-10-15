#  Cloudfront and acm cert with r53 record

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "access-identity-${aws_s3_bucket.gearpal_ui.id}"
}

# cloudfront origin access control
resource "aws_cloudfront_origin_access_control" "origin_access_control" {
  name                              = "eai-gearpal-cf-${var.environment}"
  description                       = "Origin Access Control for eai gearpal Cloudfront"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = aws_s3_bucket.gearpal_ui.bucket_regional_domain_name
    origin_id   = "s3bucket-${aws_s3_bucket.gearpal_ui.id}"
    origin_access_control_id = aws_cloudfront_origin_access_control.origin_access_control.id
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "CloudFront distribution for ${var.environment} environment using S3 bucket ${aws_s3_bucket.gearpal_ui.id}"
  default_root_object = var.s3_default_root_object
  aliases             = [ trim(lookup(var.custom_domain,var.environment), ".") ]

  logging_config {
    include_cookies = false
    bucket          = "eai-cloudfrontlogs-${var.environment}.s3.amazonaws.com"
    prefix          = var.prefix_s3_distribution
  }

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "s3bucket-${aws_s3_bucket.gearpal_ui.id}"
    cache_policy_id  = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
        viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = merge({ Name = "eai-gearpal-cf"}, var.tags)

  viewer_certificate {
    acm_certificate_arn             = aws_acm_certificate.eai_gearpal_acm_cert.arn
    cloudfront_default_certificate  = false
    minimum_protocol_version        = "TLSv1.2_2021"
    ssl_support_method              = "sni-only"
  }

   web_acl_id = aws_wafv2_web_acl.WafWebAcl.arn
}

resource "aws_route53_record" "cf_r53_alias" {
  zone_id = lookup(var.zone_id, var.environment)
  name    = lookup(var.custom_domain, var.environment)
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.s3_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.s3_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}


# Enable CloudWatch Real Time monitoring - needed for Datadog latency SLO
resource "aws_cloudfront_monitoring_subscription" "cloudfront_additional_metrics" {

  distribution_id = aws_cloudfront_distribution.s3_distribution.id

  monitoring_subscription {
    realtime_metrics_subscription_config {
      realtime_metrics_subscription_status = "Enabled"
    }
  }
}

