# IAM Role for ECS Task Role
resource "aws_iam_role" "eai_gearpal_ecs_task_role" {
  name = "${var.app_name}-ecs-task-role-${var.environment}"
  
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# IAM Policy for ecs task to access ses,apigateway,ssm parameters
resource "aws_iam_policy" "eai_gearpal_ecs_task_policy" {
  name        = "${var.app_name}-ecs-task-policy-${var.environment}"
  description = "Policy for ecs to access S3, SES, apigateway"
  policy = templatefile("${path.module}/files/policy/ecs-task-policy.json", { ENVIRONMENT = var.environment, AWS_ACCOUNT_ID = var.account, AWS_REGION = var.aws_region })
}

resource "aws_iam_role_policy_attachment" "eai_gearpal_ecs_task_policy_attachment" {
  policy_arn = aws_iam_policy.eai_gearpal_ecs_task_policy.arn
  role       = aws_iam_role.eai_gearpal_ecs_task_role.name
}


## IAM role for ecs task execution Role
resource "aws_iam_role" "eai_gearpal_ecs_task_execution_role" {
  name = "${var.app_name}-ecs-task-execution-role-${var.environment}"
  
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# IAM Policy for ecs task to access s3,ses,apigateway,ssm parameters
resource "aws_iam_policy" "eai_gearpal_ecs_task_exec_policy" {
  name        = "${var.app_name}-ecs-task-exec-policy-${var.environment}"
  description = "Policy for ecs to access S3, SES, apigateway"
  policy = templatefile("${path.module}/files/policy/ecs-task-execution-policy.json", { ENVIRONMENT = var.environment, AWS_ACCOUNT_ID = var.account, AWS_REGION = var.aws_region })
}

resource "aws_iam_role_policy_attachment" "eai_gearpal_ecs_task_exec_policy_attachment" {
  policy_arn = aws_iam_policy.eai_gearpal_ecs_task_exec_policy.arn
  role       = aws_iam_role.eai_gearpal_ecs_task_execution_role.name
}


####################### IAM role for Airflow execution Role ####################### 

resource "aws_iam_role" "eai_gearpal_airflow_execution_role" {
  name = "${var.app_name}-airflow-execution-role-${var.environment}"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": [
                    "airflow-env.amazonaws.com",
                    "airflow.amazonaws.com"
                ]
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF
  tags               = var.tags
}

# IAM Policy for airflow execution role
resource "aws_iam_policy" "eai_gearpal_airflow_exec_policy" {
  name        = "${var.app_name}-airflow-exec-policy-${var.environment}"
  description = "Policy for airflow execution role"
  policy      = templatefile("${path.module}/files/policy/airflow-execution-policy.json", { ENVIRONMENT = var.environment, AWS_ACCOUNT_ID = var.account, AWS_REGION = var.aws_region })
  tags        = var.tags
}

# Attching IAM policy to the IAM role
resource "aws_iam_role_policy_attachment" "eai_gearpal_airflow_exec_policy_attachment" {
  policy_arn = aws_iam_policy.eai_gearpal_airflow_exec_policy.arn
  role       = aws_iam_role.eai_gearpal_airflow_execution_role.name
}