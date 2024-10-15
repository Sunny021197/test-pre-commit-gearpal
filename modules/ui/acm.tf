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
# ACM certificate creation for cloudfront for S3
resource "aws_acm_certificate" "eai_gearpal_acm_cert" {
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
    for cv in aws_acm_certificate.eai_gearpal_acm_cert.domain_validation_options : cv.domain_name => {
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
  zone_id         = lookup(var.zone_id, var.environment)//aws_route53_zone.r53_zone.zone_id
}

resource "aws_acm_certificate_validation" "cert_validation" {
  provider = aws.us-e1
  certificate_arn         = aws_acm_certificate.eai_gearpal_acm_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}
