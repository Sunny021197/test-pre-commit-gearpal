# Define the Web ACL for s3 cloudfront distribution
resource "aws_wafv2_web_acl" "web_acl_s3" {
  provider                  = aws.us-e1
  name        = "${var.app_name}-${var.environment}-web_acl_s3"
  scope       = "CLOUDFRONT" # Change to "CLOUDFRONT" if using for CloudFront
  description  = "Web acl for GearPal s3 Cloudfront"
  default_action {
    allow {}
  }
  visibility_config {
    sampled_requests_enabled = true
    cloudwatch_metrics_enabled = true
    metric_name = "${var.app_name}-${var.environment}-web_acl_s3"
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
      metric_name = "AWS-AWSManagedRulesKnownBadInputsRuleSet"
    }
  }
}

# Create a CloudWatch Log Group
resource "aws_cloudwatch_log_group" "s3_waf_log" {
  provider                  = aws.us-e1
  name = "aws-waf-logs-${var.app_name}-${var.environment}-s3"
}

# Create the WAF Logging Configuration
resource "aws_wafv2_web_acl_logging_configuration" "s3_waf_log" {
  provider                  = aws.us-e1
  log_destination_configs = [
    aws_cloudwatch_log_group.s3_waf_log.arn
  ]
  resource_arn = aws_wafv2_web_acl.web_acl_s3.arn

  depends_on = [
    aws_wafv2_web_acl.web_acl_s3,
    aws_cloudwatch_log_group.s3_waf_log
  ]
}


######################################## Waf with Zscalar ip's whitelisted #####################################



## Add ip set to whitelist
resource "aws_wafv2_ip_set" "ip_set" {
  provider           = aws.us-e1
  name               = "${var.app_name}-cf-${var.environment}-waf-ip-set"
  description        = "List of IPs for ${var.app_name}"
  scope              = "CLOUDFRONT"
  ip_address_version = "IPV4"
  addresses          = local.list_of_all_ips

  tags = var.tags
}

## Managed Rule group for allow Zscaler IPs

resource "aws_wafv2_rule_group" "rule_group" {
  provider = aws.us-e1
  name     = "${var.app_name}-cf-${var.environment}-rule-group"
  scope    = "CLOUDFRONT"
  capacity = 1

  rule {
    name = "${var.app_name}-cf-${var.environment}-rule-IP"
    /*
      Users are asked to use priorities >= 1000.  This Rule Group is numbered 999, the last of the "reserved" blocks.
      Rules and groups are processed in order. See https://docs.aws.amazon.com/waf/latest/developerguide/web-acl-processing-order.html
      We can't skip this rule group, because default action is 'block', so we need to create rule with 'allow' action.
    */
    priority = 999
    action {
      allow {}
    }

    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.ip_set.arn
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.app_name}-cf-${var.environment}-waf-rule-1-metric"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.app_name}-cf-${var.environment}-rule-group-metric"
    sampled_requests_enabled   = true
  }

  tags = var.tags
}

## Web ACL for cloudfront

resource "aws_wafv2_web_acl" "WafWebAcl" {
  provider  = aws.us-e1
  name      = "${var.app_name}-cf-${var.environment}-rule-group-web-acl"
  scope     = "CLOUDFRONT"

  default_action {
    block {}
  }
  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.app_name}-cf-${var.environment}-rules-web-acl-metric"
    sampled_requests_enabled   = true
  }

  rule {
    name     = "AWSManagedRulesKnownBadInputsRuleSet"
    priority = 0

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesKnownBadInputsRuleSet"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 1

    override_action {
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
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesCommonRuleSet"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWSManagedRulesAmazonIpReputationList"
    priority = 2

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAmazonIpReputationList"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesAmazonIpReputationList"
      sampled_requests_enabled   = true
    }
  }
  rule {
    name     = "${var.app_name}-cf-${var.environment}-rule-IP-web-acl"
    priority = 999

    override_action {
      none {}
    }

    statement {
      rule_group_reference_statement {
        arn = aws_wafv2_rule_group.rule_group.arn
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.app_name}-cf-${var.environment}-rule-IP-web-acl-metric"
      sampled_requests_enabled   = true
    }
  }
}


resource "aws_cloudwatch_log_group" "WafWebAclLoggroup" {
  provider          = aws.us-e1
  name              = "aws-waf-logs-${var.app_name}-${var.environment}"
  retention_in_days = 30
}

resource "aws_wafv2_web_acl_logging_configuration" "WafWebAclLogging" {
  provider                = aws.us-e1
  log_destination_configs = [aws_cloudwatch_log_group.WafWebAclLoggroup.arn]
  resource_arn            = aws_wafv2_web_acl.WafWebAcl.arn
  depends_on = [
    aws_wafv2_web_acl.WafWebAcl,
    aws_cloudwatch_log_group.WafWebAclLoggroup
  ]
}