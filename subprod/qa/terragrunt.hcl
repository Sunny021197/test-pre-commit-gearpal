# subprod/dev/terragrunt.hcl
# local variables
locals {
  aws_account         = get_aws_account_id()
  aws_region          = "us-west-2"
  aws_region_backend  = "us-west-2"
  aws_region_cd       = "usw2"
  environment         = "qa"
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
  vpc_id  = "vpc-0f57713193b00bb85"
  list_of_ips        = ["136.226.102.0/23","136.226.104.0/23","165.225.216.0/23","165.225.32.0/23","165.225.36.0/23","136.226.100.0/23"]
  app_name = "eai-gearpal"
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
    Createdby      = "sheevam.thapa@toyota.com"
    Contact        = "EAI"
  }  
  userconversion_pk = "UserId"
  userconversion_sk = "ConversationId#Timestamp"
  userfeedbacks_pk = "ConversationId#Timestamp"
  userfeedbacks_sk = "UserId"
  userdata_pk = "UserId"
  userdata_sk = "EmailAddress"
  gptstore_pk = "GPTname"
  gptstore_sk = "EmaildAddress"
  userconversationsbb_table_name = "UserConversationsGearPal-${local.environment}"
  userfeedbackssbb_table_name = "UserFeedbacksGearPal-${local.environment}"
  userdatabb_table_name = "UserDataGearPal-${local.environment}"
  usergptbb_table_name = "GPTStoreGearPal-${local.environment}"
}
