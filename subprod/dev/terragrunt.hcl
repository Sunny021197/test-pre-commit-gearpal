# subprod/dev/terragrunt.hcl
# local variables
locals {
  aws_account         = get_aws_account_id()
  aws_region          = "us-west-2"
  aws_region_backend  = "us-west-2"
  aws_region_cd       = "usw2"
  environment         = "dev"
#   remote_state_s3_bucket = "eai-dev-tfstate-${get_aws_account_id()}"
#   dynamodb_tf_lock_table = "eai-dev-tfstate-${get_aws_account_id()}-lock"
  env_tag = "subprod"
  platform = "eai"
  #provider_switches = try(read_terragrunt_config("${get_terragrunt_dir()}/provider_switches.hcl"), " ")
}

# Generate remote state
remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket                   = "eai-${local.environment}-tfstate-${local.aws_account}"
    key                      = "eai-gearpal-${local.environment}/${path_relative_to_include()}/terraform.tfstate"
    encrypt                  = true
    dynamodb_table           = "eai-gearpal-${local.environment}-tfstate-${local.aws_account}-lock"
    region                   = local.aws_region_backend
    s3_bucket_tags = {
      Contact               = "enterpriseai@toyota.com"
      Environment           = local.environment
      Orchestration         = "Terraform"
      Name                  = "eai-${local.environment}-tfstate-${local.aws_account}"
    }
  }
}


# Generate provider
generate "provider" {
  path = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
  provider "aws" {
    region                   = "${local.aws_region}"
  }
  provider "random" {
  }
  provider "local" {
  }
  provider "null" {
  }
  provider "template" {
  }
EOF
}

# Generate versions file
generate "versions" {
  path                       = "versions.tf"
  if_exists                  = "overwrite_terragrunt"
  contents = <<EOF
    terraform {
      required_providers {
        aws = {
          source  = "hashicorp/aws"
          version = ">= 4.9.0, < 6.0.0"
        }
      }
      required_version = ">= 1.3.4"
    }
  EOF
}

# Inputs to modules
inputs = {
  account        = local.aws_account
  aws_region_backend = local.aws_region_backend
  aws_region     = local.aws_region
  aws_region_cd      = local.aws_region_cd
  environment    = local.environment
  region         = local.aws_region
  ses_email_identity = "enterpriseai@toyota.com"
  sns_email_subscription = "Notifications_EAI@internal.toyota.com"
  vpc_id  = "vpc-0e78369019b380561"
  list_of_ips        = ["136.226.102.0/23","136.226.104.0/23","165.225.216.0/23","165.225.32.0/23","165.225.36.0/23","136.226.100.0/23", "165.225.0.0/16", "136.226.81.0/24"]
  app_name = "eai-gearpal"
  redis_app_name = "eai-gp"
  redis_subnet_ids = ["subnet-09e0df2c601fdd3e3", "subnet-0ce46eaa5789085ab"]
  redis_security_group_id = "sg-0d9b2464abbc25a53"
  tags    = {
    ApplicationId          = "EAI"
    ApplicationName        = "EAI GEARPALGPT"
    ProjectName            = "EAI"
    TerraformScriptVersion = "0001"
    Job_name               = "eai"
    Terraform   = "true"
    Platform    = "EAI"
    Environment = local.environment
    ENV_Tag     = local.env_tag
    Createdby   = "sheevam.thapa@toyota.com"
    Contact     = "EAI"
    ManagedBy   = "Terraform"
  }  
  userconversion_pk = "UserId"
  userconversion_sk = "ConversationId#Timestamp"
  userfeedbacks_pk = "ConversationId#Timestamp"
  userfeedbacks_sk = "UserId"
  userdata_pk = "UserId"
  userdata_sk = "EmailAddress"
  gptstore_pk = "GPTname"
  gptstore_sk = "EmaildAddress"
  userconversationsbb_table_name = "UserConversationsGearPal"
  userfeedbackssbb_table_name = "UserFeedbacksGearPal"
  userdatabb_table_name = "UserDataGearPal"
  usergptbb_table_name = "GPTStoreGearPal"
  ecs_service_name = "eai-gearpal-service"
  security_group_ids = ["sg-025ec0e31b18d5e4e", "sg-0d9b2464abbc25a53"]
  subnets_ids = ["subnet-08d263d5ebc2d6460", "subnet-0abd4c6e7901939d5"]
  private_subnets_ids = ["subnet-0ce46eaa5789085ab", "subnet-09e0df2c601fdd3e3"]
  target_group_name = "eai-gearpal-targetgroup"
  container_name = "eai-gearpal-container"
  app_name = "eai-gearpal"
  type = "GearPal"
  port     = 2024
  protocol = "HTTP"
  listener_port = 80
  load_balancer_type  = "application"
  attribute_type  = "S"
  target_type = "ip"
  alb_health_check_path = "/health"
  alb_health_check_interval = 30
  alb_health_check_timeout  = 5
  alb_healthy_threshold = 5
  alb_unhealthy_threshold = 2
  https_protocol  = "HTTPS"
  default_logDriver = "awslogs"
  https_port  = 443
  origin_ssl_protocols  = "TLSv1.2"
  minimum_protocol_version  = "TLSv1.2_2021"
  n_virginia_region = "us-east-1"
  s3_bucket_alb_logs  = "eai-alb-logs-dev"
  prefix_alb_logs = "alb-gearpal"
  hosted_zone_name = "eai-dev.toyota.com"
  web_acl_id_cdn_distribution = "arn:aws:wafv2:us-east-1:928937340264:global/webacl/CreatedByCloudFront-a45c66fd-5919-4164-96e9-813c4c6f3789/42854282-0cea-41c5-bd77-8dab43c23bc2"
  prefix_s3_distribution  = "gearpal-dev/"
  prefix_cdn_distribution = "gearpal-api-dev/" 
  s3_default_root_object  = "index.html"
  airflow_version = "2.9.2"
  airflow_instance_class  = "mw1.xlarge"
  airflow_execution_role_arn  = "arn:aws:iam::928937340264:role/service-role/AmazonMWAA-test-airflow-5bUADy"
  airflow_webserver_access_mode = "PUBLIC_ONLY"
  dag_s3_path = "test_dag/"
  airflow_max_workers = 10
  airflow_min_workers = 1
  airflow_schedulers  = 2
  airflow_default_task_retries  = 3
  airflow_security_group_id = "sg-0f63095896db256f0" 
  log_bucket = "eai-gearpal-dev-logs"
  s3_airflow_bucket="gearpal-pdf-content"
  response_headers_policy_id = "4e2c38b9-510a-43ff-8cbf-662989b30c31"
  origin_request_policy_id  = "216adef6-5c7f-47e4-b989-5492eafa07d3"
  cache_policy_id = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
  viewer_protocol_policy =  "redirect-to-https"
  min_ttl = 0
  default_ttl = 3600
  max_ttl = 86400
  env_cloudfront_header = "DEV"
  s3_feedback_bucket = "gearpal-bug-images"
  awslogs_group     = "/ecs/eai-gearpal-dd"
}
