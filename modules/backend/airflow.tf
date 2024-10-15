# Reference the existing logging bucket
data "aws_s3_bucket" "existing_logging_bucket" {
 bucket = var.log_bucket
}

# Main S3 bucket that requires logging
resource "aws_s3_bucket" "s3_gearpal_airflow" {
 bucket = "${var.s3_airflow_bucket}"
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
 logging {
   target_bucket = data.aws_s3_bucket.existing_logging_bucket.id
   target_prefix = "${var.s3_airflow_bucket}/"  
 }
}
 

# terragrunt import aws_mwaa_environment.gearpal_airfllow eai-gearpal-dev-airflow
resource "aws_mwaa_environment" "gearpal_airflow" {
  name                   = "${var.app_name}-${var.environment}-airflow-test"
  airflow_version        = var.airflow_version
  environment_class      = var.airflow_instance_class
  execution_role_arn     = aws_iam_role.eai_gearpal_airflow_execution_role.arn
  webserver_access_mode  = var.airflow_webserver_access_mode
  source_bucket_arn      = aws_s3_bucket.s3_gearpal_airflow.arn
  dag_s3_path            = var.dag_s3_path
  max_workers            = var.airflow_max_workers
  min_workers            = var.airflow_min_workers
  schedulers             = var.airflow_schedulers

  airflow_configuration_options = {
    "core.default_task_retries" = var.airflow_default_task_retries
    "scheduler.catchup_by_default" = "True"
  }

  network_configuration {
    security_group_ids = [aws_security_group.test_airflow.id]
    subnet_ids         = var.private_subnets_ids
  }
 
  logging_configuration {
    dag_processing_logs {
      enabled   = true
      log_level = "INFO"
    }
 
    scheduler_logs {
      enabled   = true
      log_level = "INFO"
    }
 
    task_logs {
      enabled   = true
      log_level = "INFO"
    }
 
    webserver_logs {
      enabled   = true
      log_level = "INFO"
    }
 
    worker_logs {
      enabled   = true
      log_level = "INFO"
    }
  }

  tags = merge({ Name = var.app_name}, var.tags)
  weekly_maintenance_window_start = "WED:01:00"
}