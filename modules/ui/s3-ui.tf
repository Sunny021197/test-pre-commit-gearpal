resource "aws_kms_key" "eai_gearpal_kms" {
  description             = "KMS key gearpal"
  enable_key_rotation     = true
  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowAccessForKeyAdministrators",
            "Effect": "Allow",
            "Principal": {
                "AWS": [
                    "arn:aws:iam::${var.account}:role/app-admin-role",
                    "arn:aws:iam::${var.account}:role/app-readonly-role"
                ]
            },
            "Action": [
                "kms:Update*",
                "kms:Untag*",
                "kms:Tag*",
                "kms:ScheduleKeyDeletion",
                "kms:Revoke*",
                "kms:ReplicateKey",
                "kms:Put*",
                "kms:List*",
                "kms:Get*",
                "kms:Enable*",
                "kms:Disable*",
                "kms:Describe*",
                "kms:Delete*",
                "kms:Create*",
                "kms:CancelKeyDeletion"
            ],
            "Resource": "*"
        },
        {
            "Sid": "EnableUseOfIamPolicies",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::${var.account}:root"
            },
            "Action": "kms:*",
            "Resource": "*"
        },
        {
            "Sid": "AllowAccessForServicePrincipal-a0deaca776b6c0d2796e5add1b3d1c5b",
            "Effect": "Allow",
            "Principal": {
                "Service": "cloudfront.amazonaws.com"
            },
            "Action": [
                "kms:ReEncrypt*",
                "kms:GenerateDataKey*",
                "kms:Encrypt",
                "kms:DescribeKey",
                "kms:Decrypt"
            ],
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "aws:SourceArn": "arn:aws:cloudfront::${var.account}:distribution/E1Y4CGB51BJF3G"
                }
            }
        }
    ]
}
EOF
}
resource "aws_s3_bucket" "gearpal_ui" {
  bucket = "${var.app_name}-ui-${var.environment}"
  acl    = "private"  # This is the access control list for the bucket
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.eai_gearpal_kms.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
  versioning {
    enabled = true
  }
  tags = merge({ Name = var.app_name}, var.tags)
}

resource "aws_s3_bucket_policy" "gearpal_ui_bucket_policy" {
  bucket = aws_s3_bucket.gearpal_ui.id
  policy = <<EOF
  {
    "Version": "2008-10-17",
    "Id": "PolicyForCloudFrontPrivateContent",
    "Statement": [
        {
            "Sid": "AllowCloudFrontServicePrincipal",
            "Effect": "Allow",
            "Principal": {
                "Service": "cloudfront.amazonaws.com"
            },
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::eai-gearpal-ui-${var.environment}/*",
            "Condition": {
                "StringEquals": {
                    "AWS:SourceArn": "arn:aws:cloudfront::${var.account}:distribution/E1Y4CGB51BJF3G"
                }
            }
        },
        {
            "Sid": "ForceSSLOnlyAccess",
            "Effect": "Deny",
            "Principal": "*",
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:::eai-gearpal-ui-${var.environment}/*",
                "arn:aws:s3:::eai-gearpal-ui-${var.environment}"
            ],
            "Condition": {
                "Bool": {
                    "aws:SecureTransport": "false"
                }
            }
        }
    ]
}
EOF
}

# Enable server access logging for the gearpal UI bucket
resource "aws_s3_bucket_logging" "gearpal_s3_logs" {
  depends_on = [aws_s3_object.logs_folder]

  bucket = aws_s3_bucket.gearpal_ui.id

  target_bucket = aws_s3_bucket.gearpal_logs.id
  target_prefix = "s3-logs/"
}

# Create an S3 bucket for the GearPal logs
resource "aws_s3_bucket" "gearpal_logs" {
  bucket = "${var.app_name}-${var.environment}-logs"
  tags = merge({ Name = var.app_name}, var.tags)
}

# Create a folder named 's3-logs' in the S3 bucket
resource "aws_s3_object" "logs_folder" {
  depends_on = [aws_s3_bucket.gearpal_logs]

  bucket = aws_s3_bucket.gearpal_logs.bucket
  key    = "s3-logs/"
}
