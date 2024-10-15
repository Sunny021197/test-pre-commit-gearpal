variable "environment" {}
variable "aws_region" {}
variable "account" {}
variable "aws_region_backend" {}
variable "ses_email_identity" {}
variable "sns_email_subscription" {}
variable "aws_region_cd" {}
variable "vpc_id" {}
variable "image_tag" {}
variable "app_name" {}
variable "redis_app_name" {}
variable "redis_subnet_ids"{
type = list(string)
}
variable "redis_security_group_id" {}
# R53
variable "zone_id" {
  type = map(string)
  description = "Hosted Zone ID"
  default = {
    "dev" = "Z08120731DE4CQSDJPEUC"
    "prod" = "Z03204552DIRKAUJWQ3XW"
  }
}

variable "custom_domain" {
  type = map(string)
  description = "Custom domain value"
  default = {
    dev = "api.gearpal.eai-dev.toyota.com"
    prod = "api.gearpal.eai.toyota.com"
  }
}

# Lambda authorizer

variable "idp_application_id" {
  type = map(string)
  description = "Azure idp application id "
  default = {
    dev = "3b450cde-0660-4e8e-9de2-0fd845c1648a"
    prod = "3cf8e22d-fb65-4286-887e-5accc79a814a"
  }
}

variable "tenant_id" {
  type = map(string)
  description = "app tenant id"
  default = {
    dev = "9107b728-2166-4e5d-8d13-d1ffdf0351ef"
    prod = "8c642d1d-d709-47b0-ab10-080af10798fb"
  }
}

variable "api_gateway_id" {
  type = map(string)
  description = "api gateway id"
  default = {
    dev  = "703i9xbued"
    prod = "oiafulsvte"
  }
}

variable "oidc_endpoint" {
  type = map(string)
  description = "app oidc endpoint id"
  default = {
    dev = "https://login.microsoftonline.com/9107b728-2166-4e5d-8d13-d1ffdf0351ef/v2.0/.well-known/openid-configuration"
    prod = "https://login.microsoftonline.com/8c642d1d-d709-47b0-ab10-080af10798fb/v2.0/.well-known/openid-configuration"
  }
}

variable "route53_zone_name" {
  type = map(string)
  default = {
    dev = "api.gearpal.eai-dev.toyota.com"
    prod = "api.gearpal.eai.toyota.com"
  }
}

variable "tags" {
  type = map(string)
  default = {}
  description = "These tags will be used for all services created."
}

# Optional variables

variable "endpoint_type" {
  type        = string
  default     = "REGIONAL"
  description = "Type of endpoint."
}

variable "bin_media" {
  type        = list(string)
  default     = ["multipart/form-data","application/pdf"]
  description = "Binary media types that are passed through directly for non-proxy integrations."
}

variable "enable_cors" {
  type = bool
  default = true
  description = "Enable CORS for api resource"
}

# Resources

variable "root_resource_id" {
  type = string
  default = "/"
  description = "Root Resource ID"
  
}

variable "list_of_ips" {
  type = list(string)
}


# Kms key
variable "cmk_administrator_iam_arns" {
  type = map(any)
  description = "A list of IAM ARNs for users or roles who should be given administrator access to this KMS Master Key (e.g. arn:aws:iam::1234567890:user/foo)."
  default = {
    dev = ["arn:aws:iam::928937340264:role/app-admin-role","arn:aws:iam::928937340264:role/app-readonly-role"]
    prod = ["arn:aws:iam::381491847257:role/app-admin-role"]
  }
}

# ecs task resource limits

variable "task_cpu" {
  type = map(any)
  description = "CPU for ecs fargate task"
  default = {
    dev = 8192
    prod = 8192
  }
}

variable "task_memory" {
  type = map(any)
  description = "Memory for ecs fargate task"
  default = {
    dev = 16384
    prod = 16384
  }
}

variable "app_team_oidc_arn" {
  description = "The GHA OIDC role ARN for AWS.  This role arn specifically identifies the principal caller for Blueprints executed in the pipelines.  It is normally supplied by the pipeline."
  type        = string
  default = "arn:aws:iam::928937340264:role/app-readonly-role"
}

variable "userconversion_pk" {}

variable "userconversion_sk" {}

variable "userfeedbacks_pk" {}

variable "userfeedbacks_sk" {}
variable "userdata_pk" {}

variable "userdata_sk" {}
variable "gptstore_pk" {}

variable "gptstore_sk" {}

variable "awslogs_group"{}

variable "userconversationsbb_table_name" {}
variable "userdatabb_table_name" {}
variable "userfeedbackssbb_table_name" {}
variable "usergptbb_table_name" {}
variable "ecs_service_name" {}
variable "security_group_ids" {
  type = list(string)
  default = []
}
variable "subnets_ids" {
  type = list(string)
  default = []
}
variable "private_subnets_ids" {
  type = list(string)
  default = []
}
variable "target_group_name" {}
variable "container_name" {}
variable "type" {}
variable "protocol" {}
variable "port" {
  type = number
}
variable "hosted_zone_name" {}
variable "listener_port" {}
# variable "billing_mode" {}
variable "load_balancer_type" {}
variable "attribute_type" {}
variable "target_type" {}
variable "alb_health_check_path" {}
variable "alb_health_check_interval" {}
variable "alb_health_check_timeout" {}
variable "alb_healthy_threshold" {}
variable "alb_unhealthy_threshold" {}
variable "https_protocol" {}
variable "default_logDriver" {}
variable "s3_bucket_alb_logs" {}
variable "prefix_alb_logs" {}
#variable "alb_certificate_arn" {}
variable "https_port" {
  type = number
}
variable "prefix_cdn_distribution" {}
variable "airflow_version" {}
variable "airflow_instance_class" {}
variable "airflow_execution_role_arn" {}
variable "airflow_webserver_access_mode" {}
variable "log_bucket" {}
variable "dag_s3_path" {}
variable "airflow_max_workers" {}
variable "airflow_min_workers" {}
variable "airflow_schedulers" {}
variable "airflow_default_task_retries" {}
variable "airflow_security_group_id" {}
variable "s3_airflow_bucket" {}
variable "cache_policy_id" {}
variable "viewer_protocol_policy" {}
variable "min_ttl" {}
variable "default_ttl" {}
variable "max_ttl" {}
variable "env_cloudfront_header" {}
variable "response_headers_policy_id" {}
variable "origin_request_policy_id" {}
variable "s3_feedback_bucket" {}