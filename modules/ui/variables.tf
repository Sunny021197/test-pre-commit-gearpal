variable "environment" {}
variable "aws_region" {}
variable "aws_region_cd" {}
variable "account" {}
variable "aws_region_backend" {}
variable "ses_email_identity" {}
variable "app_name" {}
variable "s3_default_root_object" {}
variable "prefix_s3_distribution" {}

variable "vpc_id" {}

variable "tags" {
  type = map(string)
  default = {}
  description = "These tags will be used for all services created."
}

variable "zone_id" {
  type = map(string)
  description = "Hosted Zone ID"
  default = {
    "dev" = "Z08120731DE4CQSDJPEUC"
    "prod" = "Z03204552DIRKAUJWQ3XW"
  }
}

variable "route53_zone_name" {
  type = map(string)
  default = {
    dev = "gearpal.eai-dev.toyota.com"
    prod = "gearpal.eai.toyota.com"
  }
}

variable "domain_names" {
  type = map(any)
  description = "Custom domain value"
  default = {
    dev = ["chat.eai-dev.toyota.com"]
    prod = ["chat.eai.toyota.com"]
  }
}

variable "custom_domain" {
  type = map(any)
  description = "Custom domain value"
  default = {
    dev = "gearpal.eai-dev.toyota.com"
    prod = "gearpal.eai.toyota.com"
  }
}

variable "app_team_oidc_arn" {
  description = "The GHA OIDC role ARN for AWS.  This role arn specifically identifies the principal caller for Blueprints executed in the pipelines.  It is normally supplied by the pipeline."
  type        = string
}
variable "cmk_administrator_iam_arns" {
  type = map(any)
  description = "A list of IAM ARNs for users or roles who should be given administrator access to this KMS Master Key (e.g. arn:aws:iam::1234567890:user/foo)."
  default = {
    dev = ["arn:aws:iam::905418140758:role/app-admin-role","arn:aws:iam::905418140758:role/app-readonly-role"]
    prod = ["arn:aws:iam::381491847257:role/app-admin-role"]
  }
}

variable "cmk_service_principals" {
  description = "A list of objects describing AWS service principals who should be given the necessary permissions to use this CMK. Each object must have a 'name' attribute which is a string describing the service principal (e.g. 's3.amazonaws.com'), an 'actions' attribute which is a list of strings describing the permissions to grant the service principal, and an optional 'conditions' attribute which is a list of objects describing the conditions for the service principal to be able to use this CMK. Each of these condition objects must have a 'test' attribute which is a string describing the type of condition (e.g. 'StringLike'), a 'variable' attribute which is a string describing the condition variable (e.g. 'kms:ViaService'), and a 'values' attribute which is a list of strings describing the values for the condition variable (e.g. ['s3.ca-central-1.amazonaws.com']). Only used in for single key creation. This value is deprecated. Please use customer_master_keys to create keys."
  default = {
    dev = [{
     name    = "cloudfront.amazonaws.com"
     actions = ["kms:GenerateDataKey*",
                "kms:Encrypt",
                "kms:Decrypt",
                "kms:ReEncrypt*",
                "kms:DescribeKey"]
     conditions = [{
       test     = "StringEquals"
       variable = "aws:SourceArn"
       values   = ["arn:aws:cloudfront:::distribution/*"]
     }]
   },]
    prod = [{
     name    = "cloudfront.amazonaws.com"
     actions = ["kms:GenerateDataKey*",
                "kms:Encrypt",
                "kms:Decrypt",
                "kms:ReEncrypt*",
                "kms:DescribeKey"]
     conditions = [{
       test     = "StringEquals"
       variable = "aws:SourceArn"
       values   = ["arn:aws:cloudfront::381491847257:distribution/EO5JOL003IZR8"]
     }]
   },]
  }
}


variable "list_of_ips" {
  type = list(string)
}

variable "slug" {
  default     = null
  description = "An optional slug which will be used to namespace resources"
  type        = string
}

variable "aggregation" {
  default     = "SUM"
  description = "An aggregation method for the protection group to detect anomalies"
  type        = string
  validation {
    condition     = contains(["SUM", "MEAN", "MAX"], var.aggregation)
    error_message = "Value must be one of 'SUM', 'MEAN', 'MAX'."
  }
}

