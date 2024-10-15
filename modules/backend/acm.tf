provider "aws" {
  region  = "us-east-1"
  alias   = "us-e1"
}

provider "aws" {
  region  = "us-east-2"
  alias   = "us-e2"
}

provider "aws" {
  region  = "us-west-2"
  alias   = "us-w2"
}

# Data block to retrieve the Route 53 hosted zone based on the provided domain name
data "aws_route53_zone" "target_zone" {
  name = var.hosted_zone_name
}
# ACM certificate creation for cloudfront distribution
resource "aws_acm_certificate" "eai_gearpal_alb_acm_cert" {
  provider = aws.us-e1
  domain_name       = lookup(var.route53_zone_name, var.environment)//lookup(var.domain_name_n1, var.environment)   
  validation_method = "DNS"
  subject_alternative_names = [join("",["*.",lookup(var.route53_zone_name,var.environment)])]
    tags = merge({ Name = "eai-gearpal-cf-acm"}, var.tags)
}

// Certificates are Verified and terraform doesn't have state import of certificate verification
resource "aws_route53_record" "cert_validation" {
  provider = aws.us-e1
  for_each = {
    for cv in aws_acm_certificate.eai_gearpal_alb_acm_cert.domain_validation_options : cv.domain_name => {
      name   = cv.resource_record_name
      record = cv.resource_record_value
      type   = cv.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.target_zone.zone_id
}

resource "aws_acm_certificate_validation" "cert_validation" {
  provider = aws.us-e1
  certificate_arn         = aws_acm_certificate.eai_gearpal_alb_acm_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}


# Create an ACM certificate for the ALB
resource "aws_acm_certificate" "alb_certificate" {
   domain_name       = lookup(var.route53_zone_name, var.environment)//lookup(var.domain_name_n1, var.environment)   
   validation_method = "DNS"
   subject_alternative_names = [join("",["*.",lookup(var.route53_zone_name,var.environment)])]
   tags = merge({ Name = "eai-gearpal-alb-cf-acm"}, var.tags)
}

# DNS validation records for ALB certificate
resource "aws_route53_record" "validation_records_alb" {
  for_each = {
    for dvo in aws_acm_certificate.alb_certificate.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.target_zone.zone_id
}

# Validate the ACM certificate for ALB using DNS records
resource "aws_acm_certificate_validation" "validation_alb" {
  certificate_arn         = aws_acm_certificate.alb_certificate.arn
  validation_record_fqdns = [
    for record in aws_route53_record.cert_validation : record.fqdn
  ]
}


# Output the ARN of the ALB certificate
output "alb_certificate_resource_output" {
  value = aws_acm_certificate.alb_certificate.arn
}