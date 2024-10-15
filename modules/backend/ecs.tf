# Creating ECS cluster 
resource "aws_ecs_cluster" "fargate_cluster" {
  name = "${var.app_name}-cluster-${var.environment}"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
  

  configuration {
    execute_command_configuration {
      logging    = "OVERRIDE" # Setting the logging setting to "OVERRIDE" to enforce logging configurations
      log_configuration {
        # CloudWatch Logging 
        cloud_watch_encryption_enabled = true
        cloud_watch_log_group_name     = "/aws/ecs/${var.app_name}-cluster-${var.environment}"
      }
    }
  }
  tags = merge({ Name = "${var.app_name}-cluster"}, var.tags)
}

data "aws_subnets" "selected" {
  filter {
    name = "vpc-id"
    values = [var.vpc_id]
  }
  }

# Create an Application Load Balancer
resource "aws_lb" "gearpal_alb" {
  name               = "${var.app_name}-alb"
  internal           = false
  load_balancer_type = var.load_balancer_type
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = var.subnets_ids
  enable_deletion_protection = true
  enable_cross_zone_load_balancing = true
  tags = var.tags
  access_logs {
    bucket  = var.s3_bucket_alb_logs
    prefix  = var.prefix_alb_logs
    enabled = true
  }
  connection_logs {
    bucket  = var.s3_bucket_alb_logs
    prefix  = var.prefix_alb_logs
    enabled = true
  }
}

# Load Balancer and Target Group
resource "aws_lb_target_group" "gearpal_targetgroup" {
  name     = var.target_group_name
  port     = var.port
  protocol = var.protocol
  vpc_id   = var.vpc_id
  target_type = var.target_type

  health_check {
    path                = var.alb_health_check_path
    interval            = var.alb_health_check_interval
    timeout             = var.alb_health_check_timeout
    healthy_threshold   = var.alb_healthy_threshold
    unhealthy_threshold = var.alb_unhealthy_threshold
  }
  tags = var.tags
}

# Create a Listener for the Load Balancer
resource "aws_lb_listener" "gearpal_listener" {
  load_balancer_arn = aws_lb.gearpal_alb.id
  port              = var.https_port
  protocol          = var.https_protocol
  certificate_arn   = aws_acm_certificate.alb_certificate.arn
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"


  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.gearpal_targetgroup.id
    }             
}


# Create ecs service
resource "aws_ecs_service" "gearpal_service" {
  name            = var.ecs_service_name
  cluster         = aws_ecs_cluster.fargate_cluster.id
  task_definition = aws_ecs_task_definition.eai_gearpal_ecs_td.arn
  desired_count   = 1  # Number of tasks to run
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnets_ids
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.gearpal_targetgroup.id
    container_name   = var.app_name
    container_port   = var.port
  }

  depends_on = [aws_lb_listener.gearpal_listener]
}

# Create ecs task definition
resource "aws_ecs_task_definition" "eai_gearpal_ecs_td" {
  family                   = "${var.app_name}-td-${var.environment}"
  task_role_arn = aws_iam_role.eai_gearpal_ecs_task_role.arn
  execution_role_arn = aws_iam_role.eai_gearpal_ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = lookup(var.task_cpu, var.environment)
  memory                   = lookup(var.task_memory, var.environment)


  container_definitions = jsonencode([
    {
      name      = "${var.app_name}"
      image     = "${aws_ecr_repository.eai_gearpal_repo.repository_url}:${data.aws_ecr_image.latest_image.image_tags[0]}"
      # cpu       = lookup(var.task_cpu, var.environment)
      # memory    = lookup(var.task_memory, var.environment)
      cpu = 7168
      memory           = 16384
      memoryReservation = 12288
      essential = true
      portMappings = [
        {
          name          = "${var.app_name}"
          containerPort = var.port
          hostPort      = var.port
        }
      ],
      environment = [
        { name = "DD_API_KEY", value = "a4be628d2c747be2bcdd7869a2a80a7c" },
        { name = "DD_INSTRUMENTATION_TELEMETRY_ENABLED", value = "false" },
        { name = "DD_VERSION", value = "v1.0.0" },
        { name = "DD_RUNTIME_METRICS_ENABLED", value = "true" },
        { name = "DD_SERVICE", value = "eai-batterybrain-${var.environment}" },
        { name = "DD_NETWORK_DEVICE_MONITORING_ENABLED", value = "true" },
        { name = "DD_APM_ENABLED", value = "true" },
        { name = "DD_LOGS_INJECTION", value = "true" },
        { name = "DD_ENV", value = "eai-batterybrain-${var.environment}" },
        { name = "DD_PROFILING_ENABLED", value = "true" },
        { name = "env", value = var.environment },
      ]
      logConfiguration = {
        logDriver = "awsfirelens"
        options = {
          dd_message_key = "log"
          apikey = "a4be628d2c747be2bcdd7869a2a80a7c"
          provider = "ecs"
          dd_service = "eai-gearpal-${var.environment}"
          TLS = "on"
          dd_source = "ecs-fluentbit"
          dd_tags = "env:${var.environment}"
          
          Name = "datadog"
        }
      }
    },
    {
      name              = "log_router"
      image             = "amazon/aws-for-fluent-bit:stable"
      cpu               = 512
      memory            = 256
      essential         = true
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-create-group    = "true",
          awslogs-group = var.awslogs_group
          awslogs-region = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
      firelensConfiguration = {
        type    = "fluentbit"
        options = {
          enable-ecs-log-metadata = "true"
        }
      }
    },
    {
      name         = "dd_apm_sidecar"
      image        = "public.ecr.aws/datadog/agent:latest"
      cpu          = 512
      memory       = 256
      essential    = true
      portMappings = [
        {
          name          = "dd_apm_sidecar-8126-tcp"
          containerPort = 8126
          hostPort      = 8126
          protocol      = "tcp"
        }
      ]
      environment = [
        { name = "DD_API_KEY", value = "a4be628d2c747be2bcdd7869a2a80a7c" },
        { name = "DD_SITE", value = "datadoghq.com" },
        { name = "DD_ENABLE_DISK_COLLECTION", value = "true" },
        { name = "DD_VERSION", value = "v1.0.0" },
        { name = "DD_APM_INSTRUMENTATION_ENABLED", value = "host" },
        { name = "DD_NETWORK_DEVICE_MONITORING_ENABLED", value = "true" },
        { name = "DD_SERVICE", value = "eai-batterybrain-${var.environment}" },
        { name = "ECS_FARGATE", value = "true" },
        { name = "DD_APM_ENABLED", value = "true" },
        { name = "DD_APM_INSTRUMENTATION_LIBRARIES", value = "python" },
        { name = "DD_ENV", value = "eai-batterybrain-${var.environment}" },
      ]
      dependsOn = [
        {
          containerName = "${var.app_name}"
          condition     = "START"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-create-group    = "true",
          awslogs-group = var.awslogs_group
          awslogs-region = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
  tags = merge({ Name = "${var.app_name}-td" }, var.tags)
}


#------------------------------------------------------------------------------
# AWS Auto Scaling - CloudWatch Alarm CPU High
#------------------------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "${var.app_name}-${var.environment}-cpu-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 300
  statistic           = "Maximum"
  threshold           = 75
  datapoints_to_alarm = 2
  dimensions = {
    ClusterName = "${var.app_name}-cluster-${var.environment}"
    ServiceName = var.ecs_service_name
  }
  alarm_actions = [
    aws_appautoscaling_policy.scale_up_policy.arn,
  ]
  tags = {
    Environment = var.environment
  }
}

#------------------------------------------------------------------------------
# AWS Auto Scaling - CloudWatch Alarm CPU Low
#------------------------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  alarm_name          = "${var.app_name}-${var.environment}-cpu-low"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 300
  statistic           = "Average"
  threshold           = 25
  datapoints_to_alarm = 2
  dimensions = {
    ClusterName = "${var.app_name}-cluster-${var.environment}"
    ServiceName = var.ecs_service_name
  }
  alarm_actions = [
    aws_appautoscaling_policy.scale_down_policy.arn,
  ]
  tags = {
    Environment = var.environment
  }
}

#------------------------------------------------------------------------------
# AWS Auto Scaling - Scaling Up Policy
#------------------------------------------------------------------------------
resource "aws_appautoscaling_policy" "scale_up_policy" {
  name               = "${var.app_name}-${var.environment}-scale-up-policy"
  service_namespace  = "ecs"
  resource_id        = "service/${var.app_name}-cluster-${var.environment}/${var.ecs_service_name}"
  scalable_dimension = "ecs:service:DesiredCount"
  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 300
    metric_aggregation_type = "Maximum"
    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 1
    }
  }
  depends_on = [aws_appautoscaling_target.scale_target]
}

#------------------------------------------------------------------------------
# AWS Auto Scaling - Scaling Down Policy
#------------------------------------------------------------------------------
resource "aws_appautoscaling_policy" "scale_down_policy" {
  name               = "${var.app_name}-${var.environment}-scale-down-policy"
  service_namespace  = "ecs"
  resource_id        = "service/${var.app_name}-cluster-${var.environment}/${var.ecs_service_name}"
  scalable_dimension = "ecs:service:DesiredCount"
  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 300
    metric_aggregation_type = "Maximum"
    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = -1
    }
  }
  depends_on = [aws_appautoscaling_target.scale_target]
}

#------------------------------------------------------------------------------
# AWS Auto Scaling - Scaling Target
#------------------------------------------------------------------------------
resource "aws_appautoscaling_target" "scale_target" {
  service_namespace  = "ecs"
  resource_id        = "service/${var.app_name}-cluster-${var.environment}/${var.ecs_service_name}"
  scalable_dimension = "ecs:service:DesiredCount"
  min_capacity       = 1
  max_capacity       = 5
}