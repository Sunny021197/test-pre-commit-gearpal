# module "cf_access_logs" {
#   source = "git::git@github.com:toyota-motor-north-america/chofer-gw-terraform-aws-security.git//modules/private-s3-bucket?ref=v0.70.2"

#   name              = "${var.environment}-${var.app_name}-cloudfront-logs"
#   acl               = "log-delivery-write"
#   bucket_ownership  = "ObjectWriter"
#   tags              = var.tags
#   sse_algorithm     = "AES256" # For access logging buckets, only AES256 encryption is supported
#   enable_versioning = false
#   force_destroy     = false
#   bucket_policy_statements = {}
#   lifecycle_rules = {
#     log = {
#       prefix  = "cloudfront-logs"
#       enabled = true
#       expiration = {
#         expire_in_days = {
#           days = 30
#         }
#       }
#     }
#   }
# }

# s3 bucket for waf logs
# module "eai_gearpal_waf_s3" {
#   source = "git::git@github.com:Toyota-Motor-North-America/ace-aws-infra-modules.git//storage/s3/log-bucket?ref=master"
#   application_id   = local.application_id
#   application_name = local.application_name
#   log_bucket_name  = "aws-waf-logs-${var.app_name}-${var.environment}"
#   created_by_email = local.created_by_email
#   environment      = var.environment
#   app_team_oidc_arn = var.app_team_oidc_arn
#   lifecycle_configuration_rules = [{
#     "abort_incomplete_multipart_upload_days" : 90,
#     "enabled" : true,
#     "expiration" : {
#       "days" : 365
#     },
#     "filter_and" : null,
#     "id" : "access_logging_lifecycle",
#     "noncurrent_version_expiration" : null,
#     "noncurrent_version_transition" : null,
#     "transition" : null
#     }
#   ]
# }