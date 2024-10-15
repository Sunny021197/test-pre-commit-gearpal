resource "aws_dynamodb_table" "UserConversationsGearPal" {
  name     = var.userconversationsbb_table_name
  hash_key = var.userconversion_pk
  range_key = var.userconversion_sk
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = var.userconversion_pk
    type = "S"  // S for string attribute type
  }
  
  attribute {
    name = var.userconversion_sk
    type = "S"  // N for number attribute type
  }
  
  tags = local.common_tags
}
resource "aws_dynamodb_table" "UserFeedbacksGearPal" {
  name           = var.userfeedbackssbb_table_name
  hash_key = var.userfeedbacks_pk
  range_key = var.userfeedbacks_sk
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = var.userfeedbacks_pk
    type = "S"  // S for string attribute type
  }
  
  attribute {
    name = var.userfeedbacks_sk
    type = "S"  // N for number attribute type
  }

  tags = local.common_tags
}
resource "aws_dynamodb_table" "UserDataGearPal" {
  name           = var.userdatabb_table_name
  hash_key = var.userdata_pk
  range_key = var.userdata_sk
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = var.userdata_pk
    type = "S"  // S for string attribute type
  }
  
  attribute {
    name = var.userdata_sk
    type = "S"  // N for number attribute type
  }

  tags = local.common_tags
}
resource "aws_dynamodb_table" "GPTStoreGearPal" {
  name           = var.usergptbb_table_name
  hash_key = var.gptstore_pk
  range_key = var.gptstore_sk
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = var.gptstore_pk
    type = "S"  
  }
  
  attribute {
    name = var.gptstore_sk
    type = "S"  
  }

  tags = local.common_tags
}
