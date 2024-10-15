# Reference the existing logging bucket
data "aws_s3_bucket" "s3_existing_logging_bucket" {
 bucket = var.log_bucket
}

# Main S3 bucket that requires logging
resource "aws_s3_bucket" "s3_gearpal_feedback" {
 bucket = "${var.s3_feedback_bucket}"
 # Enable versioning 
 versioning {
   enabled = true
 }

 # Enable server-side encryption 
 server_side_encryption_configuration {
   rule {
     apply_server_side_encryption_by_default {
       sse_algorithm = "AES256"
     }
   }
 }

 # Enable bucket logging, targeting the existing logging bucket
#  logging {
#    target_bucket = data.aws_s3_bucket.s3_existing_logging_bucket.id
#    target_prefix = "${var.s3_feedback_bucket}/"  
#  }
}
 
resource "aws_s3_bucket_policy" "s3_gearpal_feedback_bucket_policy" {
  bucket = aws_s3_bucket.s3_gearpal_feedback.id
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
            "Action": "s3:*",
            "Resource": "arn:aws:s3:::${var.s3_feedback_bucket}/*",
            "Condition": {
                "StringEquals": {
                    "AWS:SourceArn": [
                        "arn:aws:cloudfront::928937340264:distribution/E1Y4CGB51BJF3G",
                        "arn:aws:cloudfront::928937340264:distribution/EJYZJHVR9LYGJ"
                    ]
                }
            }
        }
    ]
  }
EOF
}