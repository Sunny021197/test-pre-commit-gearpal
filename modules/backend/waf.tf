# Define the Web ACL for cdn cloudfront distribution
resource "aws_wafv2_web_acl" "web_acl_cdn" {
  provider                  = aws.us-e1
  name        = "${var.app_name}-${var.environment}-web_acl_cdn"
  scope       = "CLOUDFRONT" # Change to "CLOUDFRONT" if using for CloudFront
  description  = "Web acl for GearPal cdn Cloudfront"
  default_action {
    allow {}
  }
  visibility_config {
    sampled_requests_enabled = true
    cloudwatch_metrics_enabled = true
    metric_name = "${var.app_name}-${var.environment}-web_acl_cdn"
  }
  rule {
    name     = "AWS-AWSManagedRulesAmazonIpReputationList"
    priority = 0
    override_action   {
      none {}
    }
    statement {
      managed_rule_group_statement {
        vendor_name = "AWS"
        name        = "AWSManagedRulesAmazonIpReputationList"
      }
    }
    visibility_config {
      sampled_requests_enabled = true
      cloudwatch_metrics_enabled = true
      metric_name = "AWS-AWSManagedRulesAmazonIpReputationList"
    }
  }
  rule {
    name     = "AWS-AWSManagedRulesCommonRuleSet"
    priority = 1
    override_action   {
      none {}
    }
    statement {
      managed_rule_group_statement {
        vendor_name = "AWS"
        name        = "AWSManagedRulesCommonRuleSet"

        rule_action_override {
          name = "SizeRestrictions_BODY"
          action_to_use {
            allow {}
          }
        }
      }
    }
    visibility_config {
      sampled_requests_enabled = true
      cloudwatch_metrics_enabled = true
      metric_name = "AWS-AWSManagedRulesCommonRuleSet"
    }
  }
  rule {
    name     = "AWS-AWSManagedRulesKnownBadInputsRuleSet"
    priority = 2
    override_action   {
      none {}
    }
    statement {
      managed_rule_group_statement {
        vendor_name = "AWS"
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
      }
    }
    visibility_config {
      sampled_requests_enabled = true
      cloudwatch_metrics_enabled = true
      metric_name = "AWS-AWSManagedRulesKnownBadInputsRuleSet"
    }
  }
  rule {
    name     = "AWS-AWSManagedRulesSQLiRuleSet"
    priority = 3
    override_action   {
      none {}
    }
    statement {
      managed_rule_group_statement {
        vendor_name = "AWS"
        name        = "AWSManagedRulesSQLiRuleSet"
      }
    }
    visibility_config {
      sampled_requests_enabled = true
      cloudwatch_metrics_enabled = true
      metric_name = "AWS-AWSManagedRulesSQLiRuleSet"
    }
  }
}


# Create a CloudWatch Log Group
resource "aws_cloudwatch_log_group" "cdn_waf_log" {
  provider                  = aws.us-e1
  name = "aws-waf-logs-${var.app_name}-${var.environment}-cdn"
}

# Create the WAF Logging Configuration
resource "aws_wafv2_web_acl_logging_configuration" "cdn_waf_log" {
  provider                  = aws.us-e1
  log_destination_configs = [
    aws_cloudwatch_log_group.cdn_waf_log.arn
  ]
  resource_arn = aws_wafv2_web_acl.web_acl_cdn.arn

  depends_on = [
    aws_wafv2_web_acl.web_acl_cdn,
    aws_cloudwatch_log_group.cdn_waf_log
  ]
}